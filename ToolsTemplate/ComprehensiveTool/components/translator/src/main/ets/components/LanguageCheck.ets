import { allLanguages, commonLanguages } from '../common/Constant'
import { Language } from '../model/language'
import { CapsuleTab } from './CapsuleTab'

@ComponentV2
export struct LanguageCheck {
  @Param audio: boolean = false
  @Param input: string = ''
  @Param output: string = ''
  @Local currentIndex: number = 0
  @Local isShow: boolean = false
  @Local inputLanguage: string = '中文'
  @Local outputLanguage: string = '英文'
  @Local initInputLanguage: string = '中文'
  @Local initOutputLanguage: string = '英文'
  @Local initTabItems: string[] = [this.inputLanguage, this.outputLanguage]
  @Local tabItems: string[] = [this.inputLanguage, this.outputLanguage]
  @Event onChange: (inputLanguage: string, outputLanguage: string) => void = () => {
  }
  @Event onClear: () => void = () => {
  }

  aboutToAppear(): void {
    if (this.audio) {
      this.inputLanguage = '自动检测'
      this.initInputLanguage = '自动检测'
    }
    if (this.output) {
      this.outputLanguage = this.output
      this.tabItems = [this.inputLanguage, this.outputLanguage]
    }
  }

  @Monitor('input')
  onInput() {
    this.inputLanguage = this.input
    this.tabItems = [this.inputLanguage, this.outputLanguage]
  }

  checkTabPosition(text: string) {
    if (this.currentIndex === 0) {
      return text === this.inputLanguage ? FlexAlign.SpaceBetween : FlexAlign.Start
    } else {
      return text === this.outputLanguage ? FlexAlign.SpaceBetween : FlexAlign.Start
    }
  }

  showLanguageSheet(index: number) {
    this.isShow = true
    this.currentIndex = index
  }

  checkTabIcon(text: string) {
    if (this.currentIndex === 0) {
      return text === this.inputLanguage
    } else {
      return text === this.outputLanguage
    }
  }

  changeLanguage(language: Language) {
    if (this.currentIndex === 0) {
      this.inputLanguage = language.text
    } else {
      this.outputLanguage = language.text
    }
    this.tabItems = [this.inputLanguage, this.outputLanguage]
  }

  confirmLanguage() {
    this.initInputLanguage = this.inputLanguage
    this.initOutputLanguage = this.outputLanguage
    this.initTabItems = this.tabItems
    this.isShow = false
    this.onChange(this.inputLanguage, this.outputLanguage)
  }

  cancelLanguage() {
    this.inputLanguage = this.initInputLanguage
    this.outputLanguage = this.initOutputLanguage
    this.tabItems = this.initTabItems
    this.isShow = false
  }

  exchange() {
    const temp = this.inputLanguage
    this.inputLanguage = this.outputLanguage
    this.outputLanguage = temp
    this.tabItems = [this.inputLanguage, this.outputLanguage]
    this.onClear()
    this.onChange(this.inputLanguage, this.outputLanguage)
  }

  build() {
    Row() {
      Row() {
        Row() {
          Text(this.inputLanguage)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }
        .flexGrow(1)
        .justifyContent(FlexAlign.Center)

        SymbolGlyph($r('sys.symbol.chevron_down'))
          .fontSize(16)
          .fontColor([$r('sys.color.icon_primary')])
          .margin({ left: 4 })
      }
      .flexGrow(1)
      .padding({ left: 12, right: 12 })
      .height(48)
      .onClick(() => {
        this.showLanguageSheet(0)
      })

      Image($r('app.media.tran_swap'))
        .width(24)
        .height(24)
        .margin({ left: 8, right: 8 })
        .onClick(() => {
          this.exchange()
        })

      Row() {
        Row() {
          Text(this.outputLanguage)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }
        .flexGrow(1)
        .justifyContent(FlexAlign.Center)

        SymbolGlyph($r('sys.symbol.chevron_down'))
          .fontSize(16)
          .fontColor([$r('sys.color.icon_primary')])
          .margin({ left: 4 })
      }
      .flexGrow(1)
      .padding({ left: 12, right: 12 })
      .height(48)
      .onClick(() => {
        this.showLanguageSheet(1)
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ bottom: 12 })
    .bindSheet($$this.isShow, this.languageBuilder(), {
      height: 748,
      preferType: SheetType.BOTTOM,
      title: { title: '选择语言' },
      backgroundColor: $r('sys.color.background_secondary'),
    })
  }

  @Builder
  languageBuilder() {
    Column() {
      CapsuleTab({
        index: this.currentIndex,
        tabItems: this.tabItems,
        onChange: (index) => {
          this.currentIndex = index
        },
      })
      titleBuilder('常用语言')
      Column() {
        ForEach(commonLanguages, (language: Language) => {
          Row() {
            Text(language.text)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)

            if (this.checkTabIcon(language.text)) {
              SymbolGlyph($r('sys.symbol.checkmark'))
                .fontSize(24)
                .fontColor([$r('sys.color.icon_primary')])
            }
          }
          .width('100%')
          .height(48)
          .justifyContent(this.checkTabPosition(language.text))
          .onClick(() => {
            this.changeLanguage(language)
          })
        })
      }
      .padding({
        top: 4,
        bottom: 4,
        left: 12,
        right: 12,
      })
      .borderRadius(16)
      .backgroundColor(Color.White)

      titleBuilder('所有语言')
      List() {
        ForEach(allLanguages, (language: Language) => {
          ListItem() {
            Row() {
              Text(language.text)
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)

              if (this.checkTabIcon(language.text)) {
                SymbolGlyph($r('sys.symbol.checkmark'))
                  .fontSize(24)
                  .fontColor([$r('sys.color.icon_primary')])
              }
            }
            .width('100%')
            .height(48)
            .justifyContent(this.checkTabPosition(language.text))
          }
          .onClick(() => {
            this.changeLanguage(language)
          })
        })
      }
      .layoutWeight(1)
      .padding({
        top: 4,
        bottom: 4,
        left: 12,
        right: 12,
      })
      .borderRadius(16)
      .backgroundColor(Color.White)
      .margin({ bottom: 16 })

      Row({ space: 12 }) {
        Button('取消')
          .width('50%')
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .fontColor($r('sys.color.font_emphasize'))
          .onClick(() => {
            this.cancelLanguage()
          })
        Button('确定')
          .flexGrow(1)
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .fontColor($r('sys.color.font_on_primary'))
          .onClick(() => {
            this.confirmLanguage()
          })
      }
      .width('100%')
      .padding({ bottom: 12 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
  }
}

@Builder
function titleBuilder(title: string) {
  Row() {
    Text(title)
      .fontSize($r('sys.float.Subtitle_L'))
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Bold)
  }
  .width('100%')
  .padding({ top: 24, bottom: 8 })
}