import { copyText } from '../util/FormatUtil';

@ComponentV2
export struct TranslatorRes {
  controller: TextAreaController = new TextAreaController();
  @Param isAudio: boolean = false
  @Param input: string = ''
  @Param translatorRes: string = ''
  @Local inputText: string = ''
  @Event onChange: (inputText: string) => void = () => {
  }

  @Monitor('input')
  onInputChange() {
    this.inputText = this.input
  }

  build() {
    Column() {
      Column() {
        if (this.isAudio) {
          Row() {
            Text('识别结果')
              .fontSize($r('sys.float.Subtitle_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .margin({ bottom: 8 })
        }

        TextArea({
          text: $$this.inputText,
          placeholder: '请输入',
          controller: this.controller,
        })
          .placeholderFont({ size: 16, weight: 400 })
          .width('100%')
          .height(105)
          .backgroundColor('#FFFFFF')
          .borderRadius(0)
          .onChange(() => {
            this.onChange(this.inputText)
          })
      }
      .width('100%')
      .padding({ top: 16, bottom: 16 })

      Divider()
        .padding({ left: 16, right: 16 })

      Column() {
        Row() {
          Text('翻译结果')
            .fontSize($r('sys.float.Subtitle_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
          Text('复制')
            .fontSize($r('sys.float.Subtitle_S'))
            .fontColor('#0A59F7')
            .fontWeight(FontWeight.Bold)
            .enabled(this.translatorRes ? true : false)
            .opacity(this.translatorRes ? 1 : 0.4)
            .onClick(() => {
              copyText(this.translatorRes)
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 8 })
        .justifyContent(FlexAlign.SpaceBetween)

        TextArea({
          text: this.translatorRes,
          placeholder: '',
          controller: this.controller,
        })
          .placeholderFont({ size: 16, weight: 400 })
          .width('100%')
          .height(105)
          .borderRadius(0)
          .focusable(false)
          .backgroundColor('#FFFFFF')
      }
      .width('100%')
      .padding({ top: 16, bottom: 16 })
    }
    .borderRadius(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 16 })
  }
}