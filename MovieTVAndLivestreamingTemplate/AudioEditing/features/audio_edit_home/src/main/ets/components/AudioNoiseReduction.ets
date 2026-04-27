/**
 * @usage: 音频降噪处理页面,用于对音频进行降噪处理。
 * 支持去除音频中的背景噪音、杂音等,提高音频清晰度。
 * 提供降噪强度调节和实时预览功能,用户可以听到降噪效果后再保存。
 * @layout: 页面采用Column垂直布局,顶部为CommonHeader导航栏,
 * 中间为AudioNoiseReductionCom降噪组件(包含降噪强度滑块、预览按钮),
 * 底部为保存按钮和提示信息。使用Worker线程处理音频降噪任务。
 * @constraints: 必须传入音频文件路径、时长、格式等参数。
 * @domain: 音频编辑
 * @zhName: 音频降噪处理页面
 * @isGen: true
 * @fileType: page
 * @subPage: 
 * @component: AudioNoiseReductionCom,CommonHeader,BottomTips
 * @image: screenshots/audioEditHome/noiseReduction.jpg
 */
import { common } from '@kit.AbilityKit';
import { AudioNoiseReductionCom } from './AudioNoiseReductionCom';
import {
  AudioAdjustVM,
  BottomTips,
  CommonHeader,
  FileUtil,
  ProgressDialogVM,
  throttle,
  TValueType
} from 'audio_common';
import { WorkersController } from 'audio_worker';
import { phoneRouterControl } from 'oh_router';
import { promptAction } from '@kit.ArkUI';


@ComponentV2
export struct AudioNoiseReduction {
  vm: AudioAdjustVM = new AudioAdjustVM();
  @Param pageParams: TValueType = null;
  uiContext = this.getUIContext();
  @Local navPathStack: NavPathStack = new NavPathStack();
  @Param musicTitle: string = ''
  @Param sourcePath: string = '' //源文件路径
  @Param duration: number = 0 //音频时长（毫秒）
  @Param format: string = ''
  @Param resultCallBack: (outPath: string) => void = (outPath: string) => {
  }
  @Param backHandle: () => void = () => {

  }

  aboutToAppear(): void {
    this.vm.format = this.format
    this.vm.sourcePath = this.sourcePath
    this.vm.duration = this.duration
    this.vm.pageType = 'AudioNoiseReduction'
    this.vm.speedValue = 1
    this.vm.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.vm.fileUtil = new FileUtil(this.vm.context)
    this.vm.progressDialogVM = new ProgressDialogVM(this.uiContext)
    this.vm.promptActionUI = this.uiContext.getPromptAction();
    this.vm.dialogState.progressTitle = '降噪处理中...'
    this.vm.dialogState.cancel = () => {
      this.onCancel()
    }
    this.vm.saveWork = this.resultCallBack
  }

  @Builder
  audioNoiseReductionBuilder() {
    AudioNoiseReductionCom({
      getSpeedValue: (val: string) => {

        this.vm.speedValue = Number(val)
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
    this.vm.dialogState.fileTime = 60000
    const outFileName = '降噪-' + this.musicTitle
    this.vm.save(outFileName)

  }

  build() {
    NavDestination() {
      Column() {
        CommonHeader({
          title: '降噪处理',
          iconColorParam: $r('sys.color.icon_on_primary'),
          iconBackgroundColorParam: 'rgba(255,255,255,0.1)',
          backgroundColorParam: '#0A0D1E',
          fontColorParam: $r('sys.color.font_on_primary'),
          onReturnClick: () => {
            phoneRouterControl.popPage()
          },
        })

        Column() {
          Column() {
            Row() {

              Text('文件名：' + this.musicTitle)
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
              this.audioNoiseReductionBuilder()
            }.padding({
              left: 16,
              right: 16,
              top: 24,
              bottom: 24
            })
            .backgroundColor('rgba(255,255,255,0.1)')
            .margin({
              top: 12
            })
            .borderRadius(16)

          }

          Column() {
            BottomTips({
              tipText: '降噪处理',
              exportStatus: this.vm.exportStatus,
              saveResult: this.vm.saveResult
            })
            Text('保存')
              .fontSize(16)
              .fontColor($r('sys.color.black'))
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
    .onReady((ctx: NavDestinationContext) => {
      this.navPathStack = ctx.pathStack
    })
  }
}

@Builder
export function AudioNoiseReductionBuilder(params: TValueType) {
  AudioNoiseReduction({
    pageParams: params
  })
}

