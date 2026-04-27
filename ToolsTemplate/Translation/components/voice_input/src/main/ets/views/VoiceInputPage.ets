import { VoiceInputViewModel } from '../viewmodel/VoiceInputViewModel';
import { VoiceInputStatus } from '../model/VoiceInputModel';
import { common } from '@kit.AbilityKit';

/**
 * @usage: 语音输入页面组件，提供语音识别转文字功能。支持实时语音识别、音量波形显示、识别结果展示和清除。
 * 主要数据结构包括VoiceInputViewModel（语音输入视图模型）、VoiceInputStatus（语音输入状态枚举）。
 * 包含if逻辑判断识别结果显示、波形显示、按钮状态切换。
 * @layout: 页面采用NavDestination导航目的地，内部Column垂直布局。顶部为空白点击区域Column，底部为白色圆角卡片Column包含：
 * Header头部Row、识别结果区域Column（结果文本Scroll或提示文字Text）、波形显示区域Column、录音按钮区域Column。
 * @constraints: 需要麦克风权限
 * @fileType: component
 * @zhName: 语音输入页面组件
 * @isGen: true
 * @image: screenshot/translate/VoiceInputPage.jpg
 */
@ComponentV2
export struct VoiceInputPage {
  @Local vm: VoiceInputViewModel = new VoiceInputViewModel();
  pathStack: NavPathStack = new NavPathStack();
  private textScroller: Scroller = new Scroller();

  @Monitor('vm.resultText')
  onResultTextChange(): void {
    setTimeout(() => {
      this.textScroller.scrollEdge(Edge.Bottom);
    }, 50);
  }

  aboutToDisappear(): void {
    this.vm.shutdown();
  }

  build() {
    NavDestination() {
      Column() {
        Column()
          .layoutWeight(1)
          .width('100%')
          .onClick(() => {
            this.pathStack.pop();
          })

        Column() {
          this.Header()

          Column() {
            if (this.vm.resultText) {
              Row() {
                Scroll(this.textScroller) {
                  Text(this.vm.resultText)
                    .fontSize(18)
                    .fontColor('#333333')
                    .textAlign(TextAlign.Start)
                    .width('100%')
                }
                .layoutWeight(1)
                .scrollBar(BarState.Auto)
                .align(Alignment.Bottom)

                Image($r('app.media.ic_close'))
                  .width(24)
                  .height(24)
                  .fillColor('#999999')
                  .margin({ left: 12 })
                  .onClick(() => {
                    this.vm.clearResult()
                  })
              }
              .width('100%')
              .layoutWeight(1)
              .alignItems(VerticalAlign.Bottom)
            } else {
              Text(this.vm.status === VoiceInputStatus.IDLE ? '点击话筒开始语音识别' : '正在聆听中...')
                .fontSize(16)
                .fontColor('#666666')
            }
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .padding({ left: 20, right: 20 })

          Column() {
            if (this.vm.status === VoiceInputStatus.LISTENING) {
              this.WaveView()
            }
          }
          .height(50)
          .justifyContent(FlexAlign.Center)
          .width('100%')

          Column() {
            if (this.vm.resultText) {
              this.CompleteButton()
            } else {
              this.RecordButton()
            }
          }
          .padding({ bottom: 24 })
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('45%')
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 24, topRight: 24 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0, 0, 0, 0.2)')
    }
    .hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG)
    .onReady((context) => {
      this.pathStack = context.pathStack;
    })
  }

  @Builder
  Header() {
    Row() {
      Row() {
        Image($r('app.media.ic_backward2'))
          .width(32)
          .height(32)
          .objectFit(ImageFit.Contain)
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.pathStack.pop();
      })

      Blank()

      Text('语音输入')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)

      Blank()

      Blank().width(40)
    }
    .width('100%')
    .height(44)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  WaveView() {
    Row({ space: 4 }) {
      ForEach(this.vm.volumeList, (height: number) => {
        Column()
          .width(4)
          .height(height)
          .backgroundColor('#4080FF')
          .borderRadius(2)
          .animation({ duration: 100, curve: Curve.EaseInOut })
      })
    }
    .height(40)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  CompleteButton() {
    Stack() {
      Image($r('app.media.ic_complete'))
        .width(100)
        .height(100)
        .objectFit(ImageFit.Contain)
    }
    .width(100)
    .height(100)
    .onClick(() => {
      this.pathStack.pop({ text: this.vm.resultText });
    })
  }

  @Builder
  RecordButton() {
    Stack() {
      if (this.vm.status === VoiceInputStatus.IDLE) {
        Image($r('app.media.ic_voice_input'))
          .width(100)
          .height(100)
          .objectFit(ImageFit.Contain)
      } else {
        Image($r('app.media.ic_complete'))
          .width(100)
          .height(100)
          .objectFit(ImageFit.Contain)
      }
    }
    .width(100)
    .height(100)
    .onClick(async () => {
      if (this.vm.status === VoiceInputStatus.IDLE) {
        this.vm.startListening(getContext(this) as common.UIAbilityContext);
      } else {
        await this.vm.stopListening();
      }
    })
  }
}
