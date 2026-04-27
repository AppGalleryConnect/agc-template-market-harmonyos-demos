import { CommonHeader, FileUtil, ProgressDialogInfo, ProgressDialogVM, } from 'audio_common';
import { WorkersController } from 'audio_worker';
import { AudioAdjustVM } from '../viewModel/AudioAdjustVM';
import { common } from '@kit.AbilityKit';
import { formatDuration, throttle } from '../util/CommonUtil';
import { AudioExtractDialog } from '../components/AudioExtractDialog';
import { AudioFormatVM } from '../viewModel/AudioFormatVM';
import { promptAction } from '@kit.ArkUI';


@ComponentV2
export struct AudioFormatPage {
  vm: AudioAdjustVM = new AudioAdjustVM();
  dialogState: ProgressDialogInfo = new ProgressDialogInfo();
  @Local navPathStack: NavPathStack = new NavPathStack();
  uiContext = this.getUIContext();
  @Local progressDialogVM: ProgressDialogVM = new ProgressDialogVM(this.uiContext)
  @Local audioExtractionViewModel: AudioFormatVM = new AudioFormatVM();
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Param musicTitle: string = ''
  @Param duration: number = 0
  @Param sizePos: string = '0KB'
  @Param format: string = ''
  @Param sourcePath: string = ''
  @Local showExtractDialog: boolean = false;
  @Local videoDuration: number = 0; // ms
  @Local videoPath: string = '';
  @Param resultCallBack: ((outPath: string) => void) | undefined = undefined;
  @Param backHandle: () => void = () => {
  }
  fileUtil = new FileUtil(this.context);

  aboutToDisappear(): void {
    this.vm.player?.release()
  }

  onCancel(): void {
    this.vm.saveResult = true
    this.vm.exportStatus = 'cancel'
    this.vm.cancekTask()
    WorkersController.teminateWorker(this.vm.workId)
  }

  // 确认转换
  onExtractConfirm = (format: string) => {
    if (this.format.toLowerCase() === format.toLowerCase()) {
      promptAction.showToast({
        message: '相同格式不支持转换，请选择其他格式',
        duration: 2000
      });
      return;
    }
    this.showExtractDialog = false;
    let title = this.musicTitle as string
    this.startExtractionTask(format, title);
  }

  // 默认的保存并退出逻辑
  async defaultSaveAndExit(outPath: string) {
    /* 只有在组件独立使用且没有父容器提供回调时才会被触发，
     但在新的架构下，AudioExtractionHome 总是会提供回调（默认回调或外部回调），
     所以这里的逻辑主要是作为一种兜底。*/

    // 如果没有传入 resultCallBack，可以在这里提示用户或做简单的日志记录
  }

  startExtractionTask = (format: string, title: string) => {
    if (this.audioExtractionViewModel.workerId < 0 ||
      !WorkersController.hasWorker(this.audioExtractionViewModel.workerId)) {
      this.audioExtractionViewModel.workerId = WorkersController.createWorker(this.audioExtractionViewModel);
    }
    if (this.audioExtractionViewModel.workerId < 0) {
      this.getUIContext().getPromptAction().showToast({
        message: '已有任务在执行，请等待任务结束后再操作!',
        duration: 2000
      })
      return
    }
    const finalName = this.fileUtil!.generateUniquePathname('转换-' + title + '.' + format);
    this.audioExtractionViewModel.outPath = this.fileUtil.getAudioOutDir() + finalName;
    // 设置回调
    this.audioExtractionViewModel.resultCallBack = (outPath: string) => {
      // 提取成功
      this.progressDialogVM.completeDialog();

      // 延迟关闭弹窗，确保动画流畅
      setTimeout(() => {
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
        }
      }, 100);
    };

    // 启动进度弹窗
    this.dialogState.progressTitle = '格式转换中...';
    // 优先使用 videoDuration (ms)，如果没有则默认 60s
    const duration = this.videoDuration > 0 ? this.videoDuration : 60000;
    this.dialogState.fileTime = duration;
    this.dialogState.cancel = () => {
      // 取消任务
      this.audioExtractionViewModel.cancekTask();
      this.audioExtractionViewModel.workerId = -1
      promptAction.showToast({ message: '格式转换已取消' });
      // 重要：取消时也需要关闭弹窗的定时器
      this.progressDialogVM.closeDialog();
    };

    this.progressDialogVM.openDialog(this.dialogState);

    // 启动任务
    WorkersController.startTask(this.audioExtractionViewModel.workerId);
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

  // 状态文案
  @Builder
  tipsBuilder() {
    Column() {
      if (this.vm.saveResult && this.vm.exportStatus === 'unFinish') {
        Text('网络中断，格式转换已失败')
          .fontColor('#FF4B4B')
          .tipsTextStyle()
      } else if (this.vm.saveResult && this.vm.exportStatus === 'finish') {
        Text('音频转换已成功')
          .fontColor('#FFFFFF')
          .tipsTextStyle()
      } else if (this.vm.saveResult && this.vm.exportStatus === 'cancel') {
        Text('音频转换已取消')
          .fontColor('#FFFFFF')
          .tipsTextStyle()
      }
    }
    .margin({
      bottom: 10
    })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          CommonHeader({
            title: '格式转换',
            iconColorParam: $r('sys.color.icon_on_primary'),
            iconBackgroundColorParam: 'rgba(255,255,255,0.1)',
            backgroundColorParam: '#0A0D1E',
            fontColorParam: $r('sys.color.font_on_primary'),
            onReturnClick: () => {
              this.backHandle()
            },
          })

          Column() {
            Row() {
              Row() {
                Image($r('app.media.ic_music')).width(24).height(24)
              }.width(40).height(40).backgroundColor('#33FFFFFF')
              .justifyContent(FlexAlign.Center)

              Column() {
                Text(this.musicTitle)
                  .fontSize(14)
                  .fontColor(Color.White)
                  .width('100%')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .wordBreak(WordBreak.BREAK_ALL)
                  .padding({ right: 20 })
                Text() {
                  Span(`${formatDuration(this.duration)}  |  ${this.sizePos}  |  ${this.format}`)
                }.fontSize(12).fontColor('#99FFFFFF').margin({ top: 8 })
              }.layoutWeight(1).margin({ left: 12 }).alignItems(HorizontalAlign.Start)

            }
            .width('100%')
            .height(70)
            .borderRadius(16)
            .padding({ left: 16 })
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .backgroundColor('#19FFFFFF')
            .margin({ top: 12 })

            Column() {
              this.tipsBuilder()
              Text('转换')
                .fontSize(16)
                .fontColor($r('sys.color.font_primary'))
                .width('100%')
                .height(40)
                .textAlign(TextAlign.Center)
                .borderRadius(30)
                .backgroundColor('#01FCEA')
                .onClick(throttle(() => {
                  this.showExtractDialog = true
                }, 1000))
            }
            .position({ bottom: 28 })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .layoutWeight(1)

          .width('100%')
          .width('100%')
        }
        .width('100%').height('100%')
        .padding({
          left: 16,
          right: 16
        })

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
              onConfirm: this.onExtractConfirm,
              onCancel: () => {
                this.showExtractDialog = false;
              }
            })
          }
          .width('100%')
          .zIndex(1000)
          .transition(TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 300 }))
        }
      }
      .width('100%').height('100%')

    }
    .backgroundColor('#0A0D1E')
    .hideTitleBar(true)
    .onShown(() => {

    })
    .onWillDisappear(() => {


    })
    .onReady(() => {
      this.audioExtractionViewModel.tempSourcePath = this.sourcePath as string

    })
    .onBackPressed(() => {
      this.backHandle()
      return true
    })
  }
}


@Extend(Text)
function tipsTextStyle() {
  .fontSize(14)
  .fontColor('#FFFFFF')
  .backgroundColor('#202E3E')
  .borderRadius(18)
  .padding({
    top: 9,
    bottom: 8,
    left: 16,
    right: 15
  })
}