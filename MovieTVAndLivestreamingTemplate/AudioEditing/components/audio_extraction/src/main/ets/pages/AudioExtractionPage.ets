import {
  AudioSaveHeader,
  FileUtil,
  PersistenceV2Util,
  ProgressDialogInfo,
  ProgressDialogVM
} from 'audio_common';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { AudioExtractDialog } from '../components/AudioExtractDialog';
import { AudioExtractionVM } from '../viewModel/AudioExtractionVM';
import { WorkersController } from 'audio_worker';
import { PersistenceV2 } from '@kit.ArkUI';
import { fileIo, picker } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { media } from '@kit.MediaKit';
import { AudioExtractionUsage } from '../model/AudioExtractionUsage';

const TAG = 'AudioExtractionPage';

@ComponentV2
export struct AudioExtractionPage {
  @Local videoPath: string = '';
  @Local videoName: string = '';
  @Local showExtractDialog: boolean = false;
  @Local videoDuration: number = 0; // ms
  @Local audioExtractionViewModel: AudioExtractionVM = new AudioExtractionVM();
  @Local videoController: VideoController = new VideoController();
  @Local isPlaying: boolean = false;
  @Local videoThumbnail: image.PixelMap | undefined = undefined;
  @Local currentTime: number = 0; // 当前播放进度 s
  @Local totalTime: number = 0; // 总时长 s
  @Local isSliderDragging: boolean = false;
  context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  fileUtil = new FileUtil(this.context);
  // 进度弹窗相关
  uiContext = this.getUIContext();
  @Local progressDialogVM: ProgressDialogVM = new ProgressDialogVM(this.uiContext);
  @Local dialogState: ProgressDialogInfo = new ProgressDialogInfo();
  // 增加回调参数，支持外部调用
  @Param resultCallBack: ((outPath: string) => void) | undefined = undefined;
  @Param backHandle: (() => void) | undefined = undefined;
  persistenceV2Util = new PersistenceV2Util();
  // VIP 权益相关
  @Local usage: AudioExtractionUsage = PersistenceV2.connect(AudioExtractionUsage, () => new AudioExtractionUsage())!;
  @Param vipLevel: number = 0;
  @Local isAutoSelectDone: boolean = false; // 记录是否已经自动拉起过选择器

  private async selectVideo() {
    try {
      let documentSelectOptions = new picker.DocumentSelectOptions();
      documentSelectOptions.maxSelectNumber = 1;
      documentSelectOptions.fileSuffixFilters = ['.mp4', '.flv', '.avi', '.mkv', '.mov', '.3gp'];
      let documentViewPicker = new picker.DocumentViewPicker();
      documentViewPicker.select(documentSelectOptions).then(async (documentSelectResult: Array<string>) => {
        if (documentSelectResult.length > 0) {
          const uri = documentSelectResult[0];

          // 检查文件大小
          let file: fileIo.File | undefined = undefined;
          try {
            file = await fileIo.open(uri);
            const stat = await fileIo.stat(file.fd);
            const sizeInMB = stat.size / (1024 * 1024);

            if (sizeInMB > 1174) { // 1024 + 150 MB
              this.getUIContext().getPromptAction().showToast({ message: '视频文件过大，请选择1GB以内的文件' });
              if (!this.videoPath) {
                this.handleBack();
              }
              return;
            }

            // 检查视频时长
            let avMetadataExtractor = await media.createAVMetadataExtractor();
            avMetadataExtractor.fdSrc = { fd: file.fd };
            let metadata = await avMetadataExtractor.fetchMetadata();
            avMetadataExtractor.release();

            // 检查是否有音频轨道
            if (metadata.hasAudio !== 'yes') {
              this.getUIContext().getPromptAction().showToast({ message: '检测到视频内无音轨，请重新选择视频文件' });
              if (!this.videoPath) {
                setTimeout(() => {
                  this.handleBack();
                }, 2000);
              }
              return;
            }

            let durationStr = metadata.duration;
            let durationMs = parseInt(durationStr || '0');
            // 65分钟 = (60 + 5) * 60 * 1000 ms = 3900000 ms
            if (durationMs > 3900000) {
              this.getUIContext().getPromptAction().showToast({ message: '视频时长过长，请选择60分钟以内的视频' });
              if (!this.videoPath) {
                this.handleBack();
              }
              return;
            }
          } catch (e) {
          } finally {
            if (file) {
              fileIo.closeSync(file.fd);
            }
          }

          this.videoPath = uri;
          this.getVideoInfo(this.videoPath);
          this.generateThumbnail(this.videoPath);
        } else {
          if (!this.videoPath) {
            this.handleBack();
          }
        }
      }).catch((err: BusinessError) => {
        if (!this.videoPath) {
          this.handleBack();
        }
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      if (!this.videoPath) {
        this.handleBack();
      }
    }
  }

  // 统一处理返回逻辑
  handleBack() {
    // 退出前清理临时文件
    this.audioExtractionViewModel.deleteTempFile();

    if (this.backHandle) {
      this.backHandle();
    } else {
      // 如果没有外部回调，则不需要做任何事，因为已经不是 NavDestination 了
      // 但为了用户体验，可以尝试返回上一级，不过这里是组件内部，不做处理
    }
  }

  private async generateThumbnail(uri: string) {
    let file: fileIo.File | null = null;
    try {
      file = await fileIo.open(uri);

      // 1. 获取视频宽高比
      let avMetadataExtractor = await media.createAVMetadataExtractor();
      avMetadataExtractor.fdSrc = { fd: file.fd };
      let metadata = await avMetadataExtractor.fetchMetadata();
      let videoW = parseInt(metadata.videoWidth || '0');
      let videoH = parseInt(metadata.videoHeight || '0');
      avMetadataExtractor.release();

      // 2. 计算缩略图尺寸 (保持比例，限制最大边长，例如 640)
      let thumbW = 320;
      let thumbH = 240;
      if (videoW > 0 && videoH > 0) {
        const maxDim = 640;
        if (videoW > videoH) {
          thumbW = maxDim;
          thumbH = Math.round(thumbW * videoH / videoW);
        } else {
          thumbH = maxDim;
          thumbW = Math.round(thumbH * videoW / videoH);
        }
      }

      // 3. 生成缩略图
      let avImageGenerator = await media.createAVImageGenerator();
      avImageGenerator.fdSrc = { fd: file.fd };
      let pixelMap = await avImageGenerator.fetchFrameByTime(0, media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC, {
        width: thumbW,
        height: thumbH
      });
      this.videoThumbnail = pixelMap;

      avImageGenerator.release();
    } catch (e) {
    } finally {
      if (file) {
        await fileIo.close(file.fd);
      }
    }
  }

  private async getVideoInfo(uri: string) {
    const pathArr = this.fileUtil.splitFilePath(uri);
    this.videoName = decodeURIComponent(pathArr[1]);
  }

  // 检查并重置权益
  checkAndResetUsage() {
    const today = new Date().toDateString();
    // 如果是新的一天，重置计数
    if (this.usage.lastExtractDate !== today) {
      this.usage.lastExtractDate = today;
      this.usage.count = 0;
      this.usage.freeCount = 0;
      this.usage.vipCount = 0;
    }
  }

  // 检查权益并计数（用于实际消耗次数）
  checkRightsAndCount() {
    this.checkAndResetUsage();

    // 增加使用次数
    if (this.vipLevel === 0) {
      this.usage.freeCount++;
    } else if (this.vipLevel === 1) {
      this.usage.vipCount++;
    }
  }

  aboutToAppear() {
    this.checkAndResetUsage();
  }

  @Local isPlayingBeforeDialog: boolean = false; // 记录弹窗前的播放状态
  // 提取操作
  extractHandle = () => {
    // 检查权益并计数
    this.checkAndResetUsage();
    // 如果是普通用户 (vipLevel 0)，无提取次数
    if (this.vipLevel === 0) {
      this.getUIContext().getPromptAction().showToast({ message: '普通用户暂无提取次数，请升级会员解锁更多权益' });
      return;
    }
    // 如果是 VIP (vipLevel 1)，限制 10 次
    if (this.vipLevel === 1 && this.usage.vipCount >= 10) {
      this.getUIContext()
        .getPromptAction()
        .showToast({ message: 'VIP会员每天仅可提取10次，请升级终身会员解锁无限次数权益' });
      return;
    }
    // vipLevel >= 2 (超级VIP) 不限次数

    if (!this.videoPath) {
      this.getUIContext().getPromptAction().showToast({ message: '请先选择视频' });
      return;
    }

    // 记录当前的播放状态
    this.isPlayingBeforeDialog = this.isPlaying;

    // 暂停视频播放
    if (this.isPlaying) {
      this.videoController.pause();
      this.isPlaying = false;
    }

    this.showExtractDialog = true;
  }
  // 确认提取
  onExtractConfirm = (name: string, format: string) => {
    this.showExtractDialog = false;
    // 恢复之前的播放状态
    if (this.videoController && this.isPlayingBeforeDialog) {
      this.videoController.start();
      this.isPlaying = true;
    }

    let finalName = name.trim();
    if (!finalName) {
      finalName = this.fileUtil.getRandom() + '音频提取';
    }

    // 记录使用次数
    this.startExtractionTask(finalName, format);
  }
  // 开始提取任务
  startExtractionTask = (name: string, format: string) => {
    this.audioExtractionViewModel = new AudioExtractionVM();
    this.audioExtractionViewModel.workerId = WorkersController.createWorker(this.audioExtractionViewModel);

    // 准备路径
    this.audioExtractionViewModel.tempSourcePath = this.fileUtil.copyFilePath(this.videoPath);
    // 检查源文件路径是否有效
    if (!this.audioExtractionViewModel.tempSourcePath) {
      this.getUIContext().getPromptAction().showToast({ message: '源文件读取失败，请重试' });
      return;
    }

    this.audioExtractionViewModel.outPath =
      this.fileUtil.getAudioOutDir() + this.fileUtil!.generateUniquePathname('提取-' + name + '.' + format)
    this.audioExtractionViewModel.logPath = this.fileUtil.getLogOutPath();

    // 设置回调
    this.audioExtractionViewModel.resultCallBack = (outPath: string) => {
      // 提取成功
      this.progressDialogVM.completeDialog();

      // 提取成功后扣除次数
      this.checkRightsAndCount();
      PersistenceV2.save(AudioExtractionUsage);

      // 3. 延迟关闭弹窗，确保用户能看到 100% 的状态
      setTimeout(() => {
        // 在回调执行前检查页面或任务状态，如果已经取消或销毁，不执行后续逻辑
        if (this.audioExtractionViewModel.workerId === -1) {
          return;
        }

        // 再次确保关闭（防止 VM 内部关闭失败或异步问题）
        this.progressDialogVM.closeDialog();

        // 销毁 worker
        if (this.audioExtractionViewModel.workerId !== -1) {
          this.audioExtractionViewModel.release();
        }

        // 如果外部传入了回调，则优先调用外部回调
        if (this.resultCallBack) {
          try {
            this.resultCallBack(outPath);
          } catch (e) {
            // 如果回调失败，尝试调用兜底逻辑（防止无任何反馈）
            this.defaultSaveAndExit(outPath);
          }
        } else {
          // 否则执行默认的保存并提示逻辑
          this.defaultSaveAndExit(outPath);
        }
      }, 500);
    };

    // 启动进度弹窗
    this.dialogState.progressTitle = '正在提取中...';
    // 优先使用 videoDuration (ms)，如果没有则默认 60s
    const duration = this.videoDuration > 0 ? this.videoDuration : 60000;
    this.dialogState.fileTime = duration;
    this.dialogState.logoFilePath = this.audioExtractionViewModel.logPath;
    this.dialogState.cancel = () => {
      // 取消任务 - 软取消
      this.audioExtractionViewModel.onCancel();
      this.getUIContext().getPromptAction().showToast({ message: '音频提取已取消' });
      // 重要：取消时也需要关闭弹窗的定时器
      this.progressDialogVM.closeDialog();
    };

    // 重置进度弹窗状态
    this.progressDialogVM.reset();

    this.progressDialogVM.openDialog(this.dialogState);

    // 启动任务
    WorkersController.startTask(this.audioExtractionViewModel.workerId);
  }

  async defaultSaveAndExit(outPath: string) {
    // 如果没有传入 resultCallBack，可以在这里提示用户或做简单的日志记录
  }

  getFormatSize(size: number): string {
    if (!size) {
      return '0KB';
    }
    let tempSize = size / 1024; //转成KB
    let format = 'KB';
    if (tempSize > 1024) {
      tempSize = tempSize / 1024; //在转成MB
      format = 'MB';
    }
    return `${tempSize.toPrecision(2)}${format}`;
  }

  // 保存音频到本地
  async saveAudioToLocal(srcPath: string, fileName: string) {
  }

  async copyFileToUri(srcPath: string, destUri: string) {
  }

  // 格式化时间 00:00
  formatTime(seconds: number): string {
    let m = Math.floor(seconds / 60);
    let s = Math.floor(seconds % 60);
    let mStr = m < 10 ? ('0' + m) : m;
    let sStr = s < 10 ? ('0' + s) : s;
    return `${mStr}:${sStr}`;
  }

  getTitle(): string {
    let title = '音频提取';
    if (this.vipLevel === 1) {
      title += ` (剩余${10 - this.usage.vipCount}次)`;
    }
    return title;
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        AudioSaveHeader({
          title: this.getTitle(),
          buttonText: '提取',
          saveHandle: this.extractHandle,
          backHandle: () => {
            this.handleBack();
          }
        })
          .padding({ left: 16, right: 16, top: 16 }) // 增加顶部内边距以避开状态栏遮挡

        Stack({ alignContent: Alignment.Bottom }) {
          if (this.videoPath) {
            Stack() {
              // 视频组件
              Video({
                src: this.videoPath,
                previewUri: this.videoThumbnail,
                controller: this.videoController
              })
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Contain)
                .controls(false) // 隐藏原生控制条
                .autoPlay(false)
                .onPrepared((event) => {
                  this.videoDuration = event.duration * 1000; // 存为 ms
                  this.totalTime = event.duration; // 存为 s
                })
                .onUpdate((event) => {
                  if (!this.isSliderDragging) {
                    this.currentTime = event.time;
                  }
                })
                .onFinish(() => {
                  this.isPlaying = false;
                  this.currentTime = this.totalTime;
                })

              // 自定义播放/暂停按钮
              if (!this.isPlaying) {
                Image($r('app.media.ic_paly'))
                  .width(64)
                  .height(64)
                  .fillColor(Color.White)
                  .onClick(() => {
                    this.videoController.start();
                    this.isPlaying = true;
                  })
              } else {
                // 点击视频区域暂停
                Column()
                  .width('100%')
                  .height('100%')
                  .onClick(() => {
                    this.videoController.pause();
                    this.isPlaying = false;
                  })
              }
            }
            .width('100%')
            .height('100%')

            // 底部进度条
            Row() {
              Text(this.formatTime(this.currentTime))
                .fontColor(Color.White)
                .fontSize(12)
                .margin({ right: 8 })

              Slider({
                value: this.currentTime,
                min: 0,
                max: this.totalTime,
                step: 0.1,
                style: SliderStyle.OutSet
              })
                .layoutWeight(1)
                .blockColor(Color.White)
                .trackColor($r('sys.color.comp_background_secondary'))
                .selectedColor($r('sys.color.comp_background_emphasize'))
                .trackThickness(4)
                .onChange((value: number, mode: SliderChangeMode) => {
                  this.currentTime = value;
                  if (mode === SliderChangeMode.Begin || mode === SliderChangeMode.Moving) {
                    this.isSliderDragging = true;
                  } else if (mode === SliderChangeMode.End || mode === SliderChangeMode.Click) {
                    this.isSliderDragging = false;
                    this.videoController.setCurrentTime(value);
                  }
                })

              Text(this.formatTime(this.totalTime))
                .fontColor(Color.White)
                .fontSize(12)
                .margin({ left: 8 })
            }
            .width('100%')
            .padding({
              left: 12,
              right: 12,
              bottom: 12,
              top: 12
            })
            .backgroundColor('rgba(0,0,0,0.3)') // 半透明底色
          } else {
            // 没有视频时显示的占位内容，避免 Stack 塌陷
            Column() {
              Text('请先选择视频！')
                .fontSize(16)
                .fontColor(Color.White)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.selectVideo();
            })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Color.Black)
        .borderRadius(12)
        .clip(true)
        .margin({
          top: 16,
          bottom: 16,
          left: 16,
          right: 16
        })
      }
      .width('100%').height('100%')

      // 提取弹窗蒙层与内容
      if (this.showExtractDialog) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.4)')
          .onClick(() => {
            this.showExtractDialog = false;
          })
          .zIndex(999)
          .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))

        Column() {
          AudioExtractDialog({
            workerId: this.audioExtractionViewModel.workerId,
            fileName: this.videoName,
            onConfirm: this.onExtractConfirm,
            onCancel: () => {
              this.showExtractDialog = false;
              // 恢复播放状态
              if (this.videoController && this.isPlayingBeforeDialog) {
                this.videoController.start();
                this.isPlaying = true;
              }
            }
          })
        }
        .width('100%')
        .zIndex(1000)
        .transition(TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 300 }))
      }
    }
    .width('100%').height('100%')
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
      if (isVisible && currentRatio >= 1.0) {
        if (!this.videoPath && !this.isAutoSelectDone) {
          this.isAutoSelectDone = true;
          this.selectVideo();
        }
      }
    })
  }
}

@Builder
export function AudioExtractionPageBuilder() {
  AudioExtractionPage()
}
