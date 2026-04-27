import { common } from '@kit.AbilityKit';
import { AudioAdjustToneComponent } from '../components/AudioAdjustTone'
import { BottomTips, EditViewModel, ProgressDialogVM, TValueType } from 'audio_common';
import { throttle, AudioAdjustVM } from 'audio_common';
import { CommonHeader, FileUtil } from 'audio_common';
import { WorkersController } from 'audio_worker';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct AudioAdjustTone {
  vm: AudioAdjustVM = new AudioAdjustVM();
  @Param pageParams: TValueType = null;
  uiContext = this.getUIContext();
  @Local navPathStack: NavPathStack = new NavPathStack();
  @Param musicTitle: string = ''
  @Param sourcePath: string = '' //源文件路径
  @Param duration: number = 0 //音频时长（毫秒）
  @Param format: string = ''
  @Param sampleRate: number = 0 //采样率
  @Param resultCallBack: (outPath: string) => void = (outPath: string) => {
  }
  @Param backHandle: () => void = () => {

  }
  @Local editViewModel: EditViewModel = new EditViewModel()

  aboutToAppear(): void {
    this.vm.sampleRate = this.sampleRate
    this.vm.format = this.format
    this.vm.pageType = 'AudioAdjustTone'
    this.vm.sourcePath = this.sourcePath
    this.vm.duration = this.duration
    this.vm.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.vm.fileUtil = new FileUtil(this.vm.context)
    this.vm.progressDialogVM = new ProgressDialogVM(this.uiContext)
    this.vm.promptActionUI = this.uiContext.getPromptAction();
    this.vm.dialogState.progressTitle = '音频调节中...'
    this.vm.dialogState.cancel = () => {
      this.onCancel()
    }
    this.vm.saveWork = this.resultCallBack
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
    this.vm.dialogState.fileTime = this.duration
    this.vm.workId = workId
    const outFileName = '调节(' + this.vm.speedValue + 'HZ)-' + this.musicTitle
    this.vm.save(outFileName)

  }

  build() {
    NavDestination() {
      Column() {
        CommonHeader({
          title: '音频调节',
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
              AudioAdjustToneComponent({
                currentSpeed:this.vm.sampleRate,
                min: this.vm.sampleRate * 0.5,
                max: this.sampleRate * 2,
                getSpeedValue: (val: string) => {
                  this.vm.speedValue = Number(val)
                },
              })
            }.padding({
              left: 16,
              right: 16,
              top: 24,
              bottom: 17
            })
            .backgroundColor('rgba(255,255,255,0.1)')
            .margin({
              top: 12
            })
            .borderRadius(16)

          }

          Column() {
            BottomTips({
              tipText: '音频调节',
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
export function AudioAdjustTonePageBuilder(params: TValueType) {
  AudioAdjustTone({
    pageParams: params
  })
}
