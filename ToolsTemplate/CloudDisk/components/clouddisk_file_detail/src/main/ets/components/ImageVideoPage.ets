/**
 * @usage: 图片视频详情页组件，支持图片、视频、音频、PDF文件的预览和播放。关键数据结构包括FileInfo文件信息、media.AVPlayer音频播放器、
 * VideoController视频控制器。包含if逻辑根据fileType文件类型(1-图片,2-视频,3-PDF,4-音频)显示不同的预览界面和控制组件。
 * @layout: 全屏垂直布局，顶部为导航栏(返回按钮、文件名、详情按钮)，中间为文件预览区域(根据文件类型显示图片/视频/音频/PDF)，
 * 底部为控制区域(播放控制、进度条、时间显示)。所有元素居中对齐，背景为黑色。
 * @constraints: fileType文件类型不允许修改为非法值，音频视频播放URL不能为空，AVPlayer播放器状态不能手动修改
 * @isGen: true
 * @fileType: component
 * @zhName: 图片视频详情页组件
 */
import { promptAction } from '@kit.ArkUI';
import { ImageVideoPageVM } from '../viewmodel/ImageVideoPageVM';
import { media } from '@kit.MediaKit';
import { webview } from '@kit.ArkWeb';
import { RenameDialog } from 'cloud_operation_item';
import { FileBaseCheckViewModel } from 'cloud_file_base';
import { FileOperationUtil } from 'module_cloud_upload';

@Builder
export function ImageVideoPageBuilder(params: Object) {
  ImageVideoPage({ vm: params as ImageVideoPageVM })
}

@ComponentV2
struct ImageVideoPage {
  logTag: string = 'ImageVideoPage';
  @Param @Require vm: ImageVideoPageVM
  @Local routerModule: NavPathStack = new NavPathStack()
  webViewController: webview.WebviewController = new webview.WebviewController();
  delegate: webview.WebDownloadDelegate = new webview.WebDownloadDelegate();
  private videoController: VideoController = new VideoController()
  private avPlayer: media.AVPlayer | null = null
  private fileOperationUtil: FileOperationUtil = new FileOperationUtil()
  @Local fileUrl: string = ''
  @Local documentSandBoxUrl: string = ''

  build() {
    NavDestination() {
      this.buildContent()
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true)
    .onReady((context) => {
      // 获取参数
      this.routerModule = context.pathStack;
    })
  }

  async aboutToAppear() {
    this.monitorUrlChange()
    // 获取文件资源地址
    this.fileOperationUtil.getCloudFileDownloadUrl(this.vm.fileInfo.downloadUrl).then((url) => {
      this.fileUrl = url
    })
  }

  // 重新创建avPlayer播放器
  @Monitor('fileUrl')
  async monitorUrlChange() {
    try {
      if (this.vm.fileInfo.fileType === 4) {
        if (this.avPlayer) {
          this.avPlayer.release()
        }
        this.avPlayer = await media.createAVPlayer();
        this.avPlayer.url = this.fileUrl
        this.setAVPlayerCallback(this.avPlayer);
      } else if (this.vm.fileInfo.fileType === 3) {
        if (this.fileUrl === '') {
          return;
        }
        this.webViewController.loadUrl(this.fileUrl)
      }
    } catch (e) {
    }
  }

  aboutToDisappear(): void {
    // 组件消失时清理定时器
    this.clearInterval()
    if (this.avPlayer) {
      this.avPlayer.release();
    }
  }

  avSetSpeed(speed: number): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(speed);
      } catch (e) {
      }
    }
  }

  @Builder
  shareCommentBuilder() {
    Column({ space: 4 }) {
      Image(this.vm.fileInfo.fileType === 3 ? $r('app.media.operation_share') : $r('app.media.icon_share'))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text('分享')
        .fontWeight(500)
        .fontSize($r('app.float.vp_10'))
        .fontColor(this.vm.fileInfo.fileType === 3 ? 'rgba(0, 0, 0, 0.7)' : '#FFFFFF')
    }.width('25%')
  }

  // 打开重命名对话框
  private openRenameDialog() {
    promptAction.openCustomDialog({
      builder: () => {
        this.inputCustomDialog()
      },
      alignment: DialogAlignment.Center,
      width: '90%'
    })
      .then((id) => {
        this.vm.dialogId = id
      })
  }

  private CustomDialog(msg: ResourceStr, sureAction: () => void) {
    this.getUIContext().showAlertDialog({
      message: msg,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          action: () => {
          }
        },
        {
          value: '确定',
          action: () => {
            sureAction()
          }
        }
      ]
    })

  }

  @Builder
  inputCustomDialog() {
    RenameDialog({
      name: this.vm.fileInfo.removeFileBaseExtension(),
      icon: FileBaseCheckViewModel.getImageSource(this.vm.fileInfo.fileType, this.vm.fileInfo.name),
      changeCompletedAction: (success: boolean, text?: string) => {
        if (success && text !== this.vm.fileInfo.removeFileBaseExtension()) {
          let result: string = ''
          const lastDotIndex = this.vm.fileInfo.name.lastIndexOf('.');
          if (lastDotIndex === -1 || lastDotIndex === this.vm.fileInfo.name.length - 1) {
            result = text ?? ''
          } else {
            result = text ?? '' + '.' + this.vm.fileInfo.name.substring(lastDotIndex)
          }

          this.vm.fileInfo.name = result
          this.vm.renameFunc(result)
        }

        promptAction.closeCustomDialog(this.vm.dialogId)
      }
    })
  }

  // 注册avplayer回调函数
  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('seekDone', () => {
      if (this.vm.isPlaying) {
        avPlayer.play();
      }
    });

    avPlayer.on('timeUpdate', (time: number) => {
      this.vm.currentTime = time;
    })

    avPlayer.on('error', () => {
    });

    avPlayer.on('durationUpdate', (duration: number) => {
      this.vm.duration = duration;
    });

    // 状态机变化回调函数
    avPlayer.on('stateChange', async (state: string) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          avPlayer.prepare()
          avPlayer.setSpeed(this.vm.curRate)
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          this.vm.duration = avPlayer.duration
          this.vm.currentTime = avPlayer.currentTime
          this.vm.isPlaying = false
          this.avSetSpeed(this.vm.curRate)
          break;
        case 'playing': // play成功调用后触发该状态机上报
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          break;
        case 'completed': // 播放结束后触发该状态机上报
          avPlayer.stop(); //调用播放结束接口
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          avPlayer.prepare(); // 调用prepare接口初始化avplayer状态
          break;
        case 'released':
          break;
        default:
          break;
      }
    })
  }

  private clearInterval() {
    if (this.vm.intervalId) {
      clearInterval(this.vm.intervalId)
      this.vm.intervalId = 0
    }
  }

  private formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60)
    const secs = Math.floor(seconds % 60)
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }

  getTimeShowTxt(value: number) {
    let second = parseInt(((value % 60000) / 1000).toFixed(0).toString());
    let min = parseInt((value / 60000).toString());
    let minute = min < 10 ? `${0}${min}` : min;
    let seconds = second < 10 ? `${0}${second}` : second;
    return `${minute}:${seconds}`;
  }

  startPlay() {
    if (this.vm.isPlaying) {
      this.pausePlay()
      return
    }

    // 视频时长为空
    if (this.vm.duration === 0) {
      return
    }

    this.clearInterval()
    this.vm.isPlaying = true
    this.videoController.start();
    this.vm.intervalId = setInterval(() => {
      if (this.vm.isPlaying && this.vm.currentTime < this.vm.duration) {
        this.vm.currentTime += 1
        this.clearInterval()
      } else if (this.vm.currentTime >= this.vm.duration) {
        this.stopPlay();
      }
    }, 1000)
  }

  stopPlay() {
    this.vm.isPlaying = false
    this.videoController.stop()
    this.clearInterval()
    this.vm.currentTime = 0
  }

  pausePlay() {
    this.vm.isPlaying = false
    this.videoController.pause();
    this.clearInterval()
  }

  @Builder
  buildContent() {
    Column() {
      if (this.vm.fileInfo.fileType === 3) {
        Stack({ alignContent: Alignment.Top }) {

          Column() {
            Row() {
              Image($r('app.media.ic_back_black'))
                .width(40)
                .height(40)
                .onClick(() => {
                  this.vm.popPageFunc()
                })

              Text(this.vm.fileInfo.name)
                .margin({left: 8, right: 8})
                .layoutWeight(1)
                .fontSize(20)
                .fontColor($r('sys.color.black'))
                .fontWeight(FontWeight.Bold)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Image($r('app.media.ic_details'))
                .height(28)
                .width(28)
                .onClick(() => {

                })
            }
            .width('100%')
            .height(58)
            .padding({ left: 16, right: 16 })
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)

            Web({
              src: this.fileUrl,
              controller: this.webViewController
            })
              .width('100%')
              .layoutWeight(1)
              .onPageBegin(() => {
              })
              .onPageEnd(() => {
              })
              .javaScriptAccess(true)
              .fileAccess(true)
              .geolocationAccess(false)
              .domStorageAccess(true)
              .blockNetwork(false)
              .onControllerAttached(() => {
                try {
                  this.delegate.onBeforeDownload((webDownloadItem: webview.WebDownloadItem) => {
                    // 传入本地沙箱路径并开始下载
                    webDownloadItem.start(getContext().cacheDir + '/' + webDownloadItem.getSuggestedFileName());
                  })
                  this.delegate.onDownloadUpdated(() => {
                    // 下载任务进度和速度监测处理
                  })
                  this.delegate.onDownloadFailed(() => {
                    // 下载任务失败处理
                  })
                  this.delegate.onDownloadFinish((webDownloadItem: webview.WebDownloadItem) => {
                    // 下载成功通过Web重新加载本地文件打开预览
                    this.webViewController.loadUrl(`file://${getContext().cacheDir}/` +
                    webDownloadItem.getSuggestedFileName())
                  })
                  this.webViewController.setDownloadDelegate(this.delegate);
                } catch (error) {
                  // 异常处理
                }
              })

            this.imageBuilder()
          }
          .padding({
            top: 30,
            bottom: 28
          })
          .justifyContent(FlexAlign.SpaceBetween)
          .layoutWeight(1)

        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .width('100%')
        .height('100%')
        .backgroundColor($r('sys.color.comp_background_list_card'))
      } else {
        Stack({ alignContent: Alignment.Bottom }) {
          Stack({ alignContent: Alignment.Center }) {

            Column() {
              Row() {
                Image($r('app.media.ic_back_white'))
                  .width(40)
                  .height(40)
                  .onClick(() => {
                    this.vm.popPageFunc()
                  })

                Text(this.vm.fileInfo.fileType === 4 ? '音频' : this.vm.fileInfo.name)
                  .margin({left: 8, right: 8})
                  .layoutWeight(1)
                  .fontSize(20)
                  .fontColor($r('sys.color.comp_background_list_card'))
                  .fontWeight(FontWeight.Bold)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Image($r('app.media.ic_details'))
                  .height(28)
                  .width(28)
                  .onClick(() => {
                    promptAction.openCustomDialog({
                      builder: () => {
                        this.CustomDialogDetails()
                      },
                      alignment: DialogAlignment.Bottom,
                      width: '90%'
                    })
                      .then((id) => {
                        this.vm.dialogId = id
                      })
                  })
              }
              .width('100%')
              .height(58)
              .padding({ left: 16, right: 16 })
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Center)
            }
            .padding({
              top: 30
            })
            .justifyContent(FlexAlign.SpaceBetween)
            .height('100%')

            if (this.vm.fileInfo.fileType === 1) {
              Scroll() {
                Image(this.fileUrl)
                  .width('100%')
                  .objectFit(ImageFit.Fill)
                  .interpolation(this.vm.originally ? ImageInterpolation.Low : ImageInterpolation.High)
              }.height('80%')
            } else if (this.vm.fileInfo.fileType === 2) {
              Stack({ alignContent: Alignment.Bottom }) {
                this.buildVideoArea()
                Column() {
                }.width('100%')
                .height(128)
                .linearGradient({
                  direction: GradientDirection.Bottom, // 渐变方向
                  colors: [['rgba(0, 0, 0, 0)', 0.0], ['rgba(0, 0, 0, 1)', 1]]
                })
              }

            } else if (this.vm.fileInfo.fileType === 4) {
              Image($r('app.media.ic_audio'))
                .width('100%')
                .height(120)
                .objectFit(ImageFit.Contain)
                .position({ y: '25%' })

            }
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          .width('100%')
          .height('100%')
          .backgroundColor($r('sys.color.black'))

          Column() {
            if (this.vm.fileInfo.fileType === 1 && this.vm.originally) {
              Text(`查看原图 ${this.vm.fileInfo.fileSize}`)
                .fontSize('app.float.vp_12')
                .fontColor($r('sys.color.comp_background_list_card'))
                .lineHeight('app.float.vp_14')
                .padding({
                  top: 10,
                  bottom: 10,
                  left: 24,
                  right: 24
                })
                .onClick(() => {
                  this.vm.originally = false
                })
                .margin({ bottom: 32 })
                .borderColor('rgba(255, 255, 255, 0.3)')
                .backgroundColor('rgba(0, 0, 0, 0.1)')
                .borderRadius(23)
                .borderWidth(0.5)
            } else if (this.vm.fileInfo.fileType === 2) {
              Column() {
                this.timesBuilder()
              }.width('100%').justifyContent(FlexAlign.Start).alignItems(HorizontalAlign.Start)

              this.ProgressBar()
            } else if (this.vm.fileInfo.fileType === 4) {
              Text(this.vm.fileInfo.name)
                .fontColor($r('sys.color.comp_background_list_card'))
                .fontSize($r('sys.float.Body_S'))
                .fontWeight(500)
                .margin({ bottom: 20 })
              this.ProgressBar()

              Row() {
                Row() {
                }.width(60)

                Image(this.vm.isPlaying ? $r('app.media.ic_play_arrow') : $r('app.media.ic_stop_arrow'))
                  .width(50)
                  .height(50)
                  .onClick(() => {
                    if (this.vm.isPlaying) {
                      this.avPlayer?.pause()
                    } else {
                      this.avPlayer?.play()
                    }
                    this.vm.isPlaying = !this.vm.isPlaying
                  })
                this.timesBuilder()
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({ left: 45, right: 45 })
              .margin({ bottom: 40 })
              .alignItems(VerticalAlign.Center)
              .width('100%')
            }
            this.imageBuilder()
          }.justifyContent(FlexAlign.Center)
          .padding({ bottom: 28 })
        }

      }
    }
  }

  @Builder
  imageBuilder() {
    Row() {
      Column({ space: 4 }) {
        Image(this.vm.fileInfo.fileType === 3 ? $r('app.media.operation_download') : $r('app.media.icon_download'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
        Text('下载')
          .fontWeight(500)
          .fontSize($r('app.float.vp_10'))
          .fontColor(this.vm.fileInfo.fileType === 3 ? 'rgba(0, 0, 0, 0.7)' : '#FFFFFF')
      }.width('25%')
      .onClick(() => {
        this.vm.downloadFunc()
      })

      Column({ space: 4 }) {
        Image(this.vm.fileInfo.fileType === 3 ? $r('app.media.operation_delete') : $r('app.media.icon_delete'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
        Text('删除')
          .fontWeight(500)
          .fontSize($r('app.float.vp_10'))
          .fontColor(this.vm.fileInfo.fileType === 3 ? 'rgba(0, 0, 0, 0.7)' : '#FFFFFF')
      }.width('25%')
      .onClick(() => {
        promptAction.openCustomDialog({
          builder: () => {
            this.CustomDialog('是否删除？', () => {
              this.vm.deleteFunc()
              this.vm.popPageFunc()
              return true
            })
          },
          alignment: DialogAlignment.Bottom,
          width: '90%'
        })
          .then((id) => {
            this.vm.dialogId = id
          })
      })

      Column({ space: 4 }) {
        Image(this.vm.fileInfo.fileType === 3 ? $r('app.media.operation_share') : $r('app.media.icon_share'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
        Text('分享')
          .fontWeight(500)
          .fontSize($r('app.float.vp_10'))
          .fontColor(this.vm.fileInfo.fileType === 3 ? 'rgba(0, 0, 0, 0.7)' : '#FFFFFF')
      }.width('25%')
      .onClick(() => {
        this.vm.shareFunc()
      })

      Column({ space: 4 }) {
        Image(this.vm.fileInfo.fileType === 3 ? $r('app.media.operation_rename') : $r('app.media.icon_rename'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
        Text('重命名')
          .fontWeight(500)
          .fontSize($r('app.float.vp_10'))
          .fontColor(this.vm.fileInfo.fileType === 3 ? 'rgba(0, 0, 0, 0.7)' : '#FFFFFF')
      }.width('25%')
      .onClick(() => {
        this.openRenameDialog()
      })
    }.width('100%')
    .padding({ top: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  buildVideoArea() {
    Stack({ alignContent: Alignment.Center }) {
      // 视频播放组件
      Video({
        src: this.fileUrl,
        previewUri: this.vm.fileInfo.thumbnailUrl,
        controller: this.videoController,
        currentProgressRate: this.vm.curRate
      })
        .autoPlay(false)
        .controls(false)
        .width('100%')
        .height('80%')
        .objectFit(ImageFit.Contain)
        .onPrepared((event) => {
          this.vm.duration = event.duration
        })
        .onUpdate((event) => {
          this.vm.currentTime = event.time
        })
        .onClick(() => {
          this.pausePlay();
        })
      if (!this.vm.isPlaying) {
        Image($r('app.media.ic_stop_arrow'))
          .width(50)
          .height(50)
          .onClick(() => {
            this.startPlay();
          })
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  timesBuilder() {
    Image(this.vm.imgTimes[this.vm.currentIndex]).width(40).height(40).margin({ left: 20 })
      .onClick(() => {
        promptAction.openCustomDialog({
          builder: () => {
            this.CustomDialogTimes()
          },
          alignment: DialogAlignment.Center,
          width: '90%'
        })
          .then((id) => {
            this.vm.dialogId = id
          })
      })
  }

  @Builder
  ProgressBar() {
    Row() {
      // 当前时间
      Text(this.vm.fileInfo.fileType === 2 ? this.formatTime(this.vm.currentTime) :
      this.getTimeShowTxt(this.vm.currentTime))
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.comp_background_list_card'))
        .margin({ right: 20 })
        .textAlign(TextAlign.Start)

      Slider({
        value: this.vm.currentTime,
        min: 0,
        max: this.vm.duration,
        step: 1,
        style: SliderStyle.OutSet
      })
        .blockColor($r('sys.color.comp_background_list_card'))
        .trackColor($r('sys.color.comp_background_secondary'))
        .selectedColor($r('sys.color.comp_background_emphasize'))
        .width('65%')
        .onChange((value: number) => {
          // 拖动时更新当前时间显示
          this.vm.currentTime = value;
          if (this.vm.fileInfo.fileType === 2) {
            // 重新定位视频播放位置
            this.videoController.setCurrentTime(this.vm.currentTime, SeekMode.Accurate)
          } else if (this.vm.fileInfo.fileType === 4) {
            // 如果是音频，先暂停，后移动
            this.avPlayer?.seek(this.vm.currentTime, media.SeekMode.SEEK_CLOSEST)
          }
        })


      // 总时长
      Text(this.vm.fileInfo.fileType === 2 ? this.formatTime(this.vm.duration) :
      this.getTimeShowTxt(this.vm.duration))
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.comp_background_list_card'))
        .margin({ left: 20 })
        .textAlign(TextAlign.End)
    }
    .width('85%')
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: this.vm.fileInfo.fileType === 2 ? 58 : 24 })
  }

  @Builder
  CustomDialogTimes() {
    Column() {
      ForEach(this.vm.timesList, (item: string, index: number) => {
        Row() {
          Text(item).fontSize($r('sys.float.Body_M')).fontColor(this.vm.currentIndex === index ? '#2FAFFF' : '#000000')
        }
        .padding({ top: 16, bottom: 16 })
        .justifyContent(FlexAlign.Center)
        .flexGrow(1)
        .onClick(() => {
          this.vm.currentIndex = index
          this.vm.curRate = parseFloat(this.vm.timesList[index].replace(/[^\d.]/g, ''))
          promptAction.closeCustomDialog(this.vm.dialogId)
        })
      }, (item: string) => item)

      Text('取消')
        .fontColor('rgba(0, 0, 0, 0.6)')
        .fontSize($r('sys.float.Body_M'))
        .lineHeight(40)
        .margin({ top: 12 })
        .onClick(() => {
          promptAction.closeCustomDialog(this.vm.dialogId)
        })
    }.width('100%').padding({ top: 16, bottom: 16 }).justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  CustomDialogDetails() {
    Column() {
      Row() {
        if (this.vm.fileInfo.fileType === 1) {
          Image(this.fileUrl)
            .width(40)
            .height(40)
            .borderRadius(12)
        } else if (this.vm.fileInfo.fileType === 2) {
          Image($r('app.media.ic_video'))
            .width(40)
            .height(40)
            .borderRadius(12)
        } else if (this.vm.fileInfo.fileType === 4) {
          Image($r('app.media.ic_audio'))
            .width(40)
            .height(40)
            .borderRadius(12)
        }

        Column() {
          Text(this.vm.fileInfo.name)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.black'))

          Text(this.vm.fileInfo.createTime)
            .fontSize(11)
            .fontColor('rgba(0, 0, 0, 0.30)')
        }
        .layoutWeight(1)
        .height(40)
        .padding({ left: 12, right: 12 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)

        Image($r('app.media.ic_close')).width(20).height(20)
          .onClick(() => {
            promptAction.closeCustomDialog(this.vm.dialogId)
          })
      }.height(40).alignItems(VerticalAlign.Top).margin({ bottom: 24 })

      Row() {
        Text('修改时间').fontSize(16).fontColor($r('sys.color.black')).fontWeight(FontWeight.Medium)
        Text(this.vm.fileInfo.updateTime).fontSize(16).fontColor('rgba(0, 0, 0, 0.7)').fontWeight(FontWeight.Normal)
      }.justifyContent(FlexAlign.SpaceBetween).height(47).width('100%')

      Row() {
        Text('拍摄时间').fontSize(16).fontColor($r('sys.color.black')).fontWeight(FontWeight.Medium)
        Text(this.vm.fileInfo.createTime).fontSize(16).fontColor('rgba(0, 0, 0, 0.7)').fontWeight(FontWeight.Normal)
      }.justifyContent(FlexAlign.SpaceBetween).height(47).width('100%')

      Row() {
        Text('尺寸').fontSize(16).fontColor($r('sys.color.black')).fontWeight(FontWeight.Medium)
        Text(this.vm.fileInfo.resolution).fontSize(16).fontColor('rgba(0, 0, 0, 0.7)').fontWeight(FontWeight.Normal)
      }.justifyContent(FlexAlign.SpaceBetween).height(47).width('100%')

      Row() {
        Text('文件大小').fontSize(16).fontColor($r('sys.color.black')).fontWeight(FontWeight.Medium)
        Text(this.vm.fileInfo.fileSize).fontSize(16).fontColor('rgba(0, 0, 0, 0.7)').fontWeight(FontWeight.Normal)
      }.justifyContent(FlexAlign.SpaceBetween).height(47).width('100%')

      Row() {
        Text('文件路径').fontSize(16).fontColor($r('sys.color.black')).fontWeight(FontWeight.Medium)
        Text(this.vm.fileInfo.path)
          .fontSize(16)
          .fontColor('rgba(0, 0, 0, 0.7)')
          .fontWeight(FontWeight.Normal)
          .constraintSize({
            maxWidth: '60%'
          })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }.justifyContent(FlexAlign.SpaceBetween).height(47).width('100%')
    }.width('100%').padding(24)
  }
}

