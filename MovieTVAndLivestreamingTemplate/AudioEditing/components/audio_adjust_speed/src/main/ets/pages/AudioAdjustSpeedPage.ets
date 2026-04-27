import { common } from '@kit.AbilityKit';
import { AudioAdjustSpeedComponent } from '../components/AudioAdjustSpeed'
import { BottomTips, PCMPlayer, PlayCallBack, ProgressDialogInfo, ProgressDialogVM, TValueType } from 'audio_common';
import { CommonHeader, FileUtil, EditViewModel, throttle, AudioAdjustVM } from 'audio_common';
import { WorkersController } from 'audio_worker';
import { MediaTools } from '../util/MediaTools';
import { audio } from '@kit.AudioKit';
import { promptAction } from '@kit.ArkUI';


@ComponentV2
export struct AudioAdjustSpeed {
  @Param musicTitle: string = ''
  @Param pcmPath: string = '' //pcm路径
  @Param sourcePath: string = '' //源文件路径
  @Param channelLayout: number = 0 //声道数量
  @Param sampleRate: number = 0 //采样率
  @Param duration: number = 0 //音频时长（毫秒）
  @Param sampleFormat: number = 0 //音频时长（毫秒）
  @Param format: string = ''
  @Param resultCallBack: (outPath: string) => void = (outPath: string) => {
  }
  @Param backHandle: () => void = () => {

  }
  vm: AudioAdjustVM = new AudioAdjustVM();
  @Local editViewModel: EditViewModel = new EditViewModel()
  dialogState: ProgressDialogInfo = new ProgressDialogInfo();
  @Param pageParams: TValueType = null;
  uiContext = this.getUIContext();
  @Local navPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.vm.format = this.format
    this.vm.pageType = 'AudioAdjustSpeed'
    this.vm.speedValue = 1
    this.vm.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.vm.fileUtil = new FileUtil(this.vm.context)
    this.vm.sourcePath = this.sourcePath
    this.vm.duration = this.duration
    this.vm.progressDialogVM = new ProgressDialogVM(this.uiContext)
    this.vm.promptActionUI = this.uiContext.getPromptAction();
    this.vm.dialogState.progressTitle = '音频调速中...'
    this.vm.dialogState.cancel = () => {
      this.onCancel()
    }
    const playCallBack: PlayCallBack = {
      onDurationCallBack: this.editViewModel.onDurationCallBack,
      stopCallBack: this.editViewModel.stopCallBack
    }
    this.vm.pcmPlayer =
      new PCMPlayer(this.pcmPath, this.sampleRate!, this.channelLayout!, 4,
        audio.StreamUsage.STREAM_USAGE_MUSIC, false)
    this.editViewModel.init(this.pcmPath, this.channelLayout!, this.sampleRate!,
      this.duration!)

    this.vm.pcmPlayer.initCallBack(playCallBack)
    this.vm.pcmPlayer.init()
    this.vm.saveWork = this.resultCallBack

  }

  onPageHide(): void {
    this.vm.pcmPlayer?.release()
  }

  @Builder
  audioAdjustSpeedBuilder() {
    AudioAdjustSpeedComponent({
      getSpeedValue: (val: string) => {
        this.vm.speedValue = Number(val)
        this.vm.pcmPlayer?.setSpeed(this.vm.speedValue)
      },
    })
  }

  onCancel(): void {
    this.vm.saveResult = true
    this.vm.exportStatus = 'cancel'
    setTimeout(() => {
      this.vm.saveResult = false
    }, 3000)
  }

  save() {
    let workId = WorkersController.createWorker(this.vm)
    if (workId < 0) {
      promptAction.showToast({ message: '已有任务在执行，请等待任务结束后在操作!' });
      return
    }
    this.vm.workId = workId
    this.vm.dialogState.fileTime = this.duration / this.vm.speedValue //处理弹框时长
    const outFileName = '调速-' + this.musicTitle
    this.vm.save(outFileName)

  }

  aboutToDisappear(): void {
    this.vm.pcmPlayer?.release()
  }

  @Builder
  audioControlBuilder() {
    Row() {
      Image(this.editViewModel.playStatus ? $r('app.media.audio_pause') : $r('app.media.audio_play'))
        .width(16)
        .height(16)
        .objectFit(ImageFit.Cover)
        .margin({
          right: 18
        })
        .onClick(() => {

          if (this.editViewModel.playStatus) {
            this.vm.pcmPlayer?.pause()
          } else {
            if (this.editViewModel.isOver) {
              this.vm.pcmPlayer?.skipPlay(-this.editViewModel.size, this.editViewModel.size)
              this.editViewModel.skipSecond(-Math.floor(this.duration / 1000))
              this.vm.pcmPlayer?.start()
              this.editViewModel.isOver = false
            } else {
              this.vm.pcmPlayer?.setSpeed(this.vm.speedValue)
              this.vm.pcmPlayer?.start()
            }
          }
          this.editViewModel.playStatus = !this.editViewModel.playStatus


        })
      Row() {
        Text(MediaTools.msToCountdownTime(this.editViewModel.playTime * 1000))
          .timeTextStyle()

        Column() {
          Slider({
            min: 0,
            max: Math.floor(this.duration / 1000),
            step: 1,
            value: this.editViewModel.playTime,
            style: SliderStyle.NONE
          })

            .selectedColor('#01FCEA')
            .trackColor('rgba(255,255,255,0.1)')
            .onChange((value: number, mode: SliderChangeMode) => {

              if (mode === SliderChangeMode.End) {

                let skipNum = value - this.editViewModel.playTime - 1;
                //处理音频跳帧播放
                const skipBuffer =
                  skipNum * this.editViewModel.sampleRate * this.editViewModel.channelLayout *
                  this.editViewModel.bytesPerSample
                this.vm.pcmPlayer?.skipPlay(skipBuffer, this.editViewModel.size)
                this.editViewModel.skipSecond(skipNum)
                this.vm.pcmPlayer?.start()
              }
            })
            .height(16)
        }.layoutWeight(1)
        .margin({
          left: 16,
          right: 16,
        })

        Text(MediaTools.msToCountdownTime(this.duration!))
          .timeTextStyle()
      }.layoutWeight(1)
    }
    .width('100%')
    .margin({
      top: 44
    })
  }

  build() {
    NavDestination() {
      Column() {
        CommonHeader({
          title: '音频调速',
          iconColorParam: $r('sys.color.icon_on_primary'),
          iconBackgroundColorParam: 'rgba(255,255,255,0.1)',
          backgroundColorParam: '#0A0D1E',
          fontColorParam: $r('sys.color.font_on_primary'),
          onReturnClick: () => {
            this.backHandle()
          },
        })

        Column() {
          Column() {
            Row() {

              Text('文件名：' + this.musicTitle || '添加音频')
                .fontColor($r('sys.color.font_on_primary'))
                .fontSize(16)
                .textOverflow({
                  overflow: TextOverflow.Ellipsis
                })
                .wordBreak(WordBreak.BREAK_ALL)
                .width('100%')
                .maxLines(1)
            }
            .width('100%')
            .margin({
              top: 11
            })
            .padding({
              left: 16,
              right: 16,
              top: 16,
              bottom: 17
            })
            .backgroundColor('rgba(255,255,255,0.1)')
            .borderRadius(16)

            Row() {
              this.audioAdjustSpeedBuilder()
            }.padding({
              left: 16,
              right: 16,
              top: 20,
              bottom: 30
            })
            .backgroundColor('rgba(255,255,255,0.1)')
            .margin({
              top: 12
            })
            .borderRadius(16)

            this.audioControlBuilder()

          }

          Column() {
            BottomTips({
              tipText: '音频调速',
              exportStatus: this.vm.exportStatus,
              saveResult: this.vm.saveResult
            })
            Text('保存')
              .fontSize(16)
              .fontColor('#000000')
              .borderRadius(20)
              .textAlign(TextAlign.Center)
              .width('100%')
              .height(40)
              .backgroundColor('#01FCEA')
              .onClick(throttle(() => {
                this.save()
              }, 1000))
          }
          .position({ bottom: 28 })
          .width('100%')
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1)

        .width('100%')
      }
      .width('100%').height('100%')
    }
    .backgroundColor('#0A0D1E')
    .padding({
      left: 16,
      right: 16
    })
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => this.navPathStack = ctx.pathStack)

  }
}

@Builder
export function AudioAdjustSpeedPageBuilder(params: TValueType) {
  AudioAdjustSpeed({
    pageParams: params
  })
}

@Extend(Text)
function timeTextStyle() {
  .fontColor($r('sys.color.font_on_primary'))
  .fontSize(12)
  .lineHeight('14vp')
  .lineHeight('14vp')
}

