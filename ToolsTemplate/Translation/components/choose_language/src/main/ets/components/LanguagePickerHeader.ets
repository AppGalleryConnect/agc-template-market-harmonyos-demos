import { LanguageListConstants, IconSizeConstants } from '../constants/LanguageConstants';

/**
 * @usage: 语言选择器头部组件，用于语言选择页面的顶部导航栏。包含返回按钮、源语言选择、目标语言选择和语言交换功能。
 * 主要数据结构包括sourceLanguageName（源语言名称）、targetLanguageName（目标语言名称）、各种显示控制标志。
 * 包含if逻辑判断语言选择器、交换按钮、下拉箭头的显示。
 * @layout: 组件采用Row横向布局。左侧为返回按钮Button，中间为语言选择区域Row（源语言Row、交换按钮Row、目标语言Row），右侧为占位元素Row
 （居中时）。
 * @constraints: 无
 * @isGen: true
 * @fileType: component
 * @zhName: 语言选择器头部组件
 * @image: screenshot/translate/LanguagePickerHeader.jpg
 */
@ComponentV2
export struct LanguagePickerHeader {
  // 必需参数
  @Param @Require onReturnClick: () => void
  @Param @Require sourceLanguageName: string
  @Param @Require targetLanguageName: string
  // 可选参数
  @Param showSourceLanguageSelect: boolean = false
  @Param showTargetLanguageSelect: boolean = false
  @Param showSwapButton: boolean = false
  @Param sourceLanguageHighlight: boolean = false
  @Param targetLanguageHighlight: boolean = false
  @Param centerLanguageSelector: boolean = false
  @Param useUpArrowForTarget: boolean = false
  // 事件回调
  @Event onSourceLanguageClick?: () => void
  @Event onTargetLanguageClick?: () => void
  @Event onSwapClick?: () => void
  // 背景色
  @Param headerBackgroundColor: ResourceColor = Color.White

  build() {
    Row() {
      // 返回按钮
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width(40)
      .height(40)
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.onReturnClick()
      })

      // 语言选择区域
      Row() {
        // 源语言选择
        Row({ space: 4 }) {
          Text(this.sourceLanguageName)
            .fontSize(LanguageListConstants.HEADER_FONT_SIZE)
            .fontColor(this.showSourceLanguageSelect && this.sourceLanguageHighlight ?
            $r('sys.color.icon_emphasize') : $r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          if (this.showSourceLanguageSelect) {
            Image($r('app.media.select'))
              .width(IconSizeConstants.DROPDOWN_ICON_SIZE)
              .height(IconSizeConstants.DROPDOWN_ICON_SIZE)
              .objectFit(ImageFit.Contain)
          }
        }
        .padding({ left: 8, right: 8 })
        .height(40)
        .onClick(() => {
          if (this.showSourceLanguageSelect && this.onSourceLanguageClick) {
            this.onSourceLanguageClick()
          }
        })

        // 交换按钮
        if (this.showSwapButton) {
          Row() {
            Image($r('app.media.switch'))
              .width(IconSizeConstants.SWITCH_ICON_SIZE)
              .height(IconSizeConstants.SWITCH_ICON_SIZE)
              .objectFit(ImageFit.Contain)
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            if (this.onSwapClick) {
              this.onSwapClick()
            }
          })
        }

        // 目标语言选择
        Row({ space: 4 }) {
          Text(this.targetLanguageName)
            .fontSize(LanguageListConstants.HEADER_FONT_SIZE)
            .fontColor(this.targetLanguageHighlight ? $r('sys.color.icon_emphasize') : $r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          if (this.showTargetLanguageSelect) {
            Image(this.useUpArrowForTarget ? $r('app.media.choose_liang') : $r('app.media.select'))
              .width(IconSizeConstants.DROPDOWN_ICON_SIZE)
              .height(IconSizeConstants.DROPDOWN_ICON_SIZE)
              .objectFit(ImageFit.Contain)
          }
        }
        .padding({ left: 8, right: 8 })
        .height(40)
        .onClick(() => {
          if (this.showTargetLanguageSelect && this.onTargetLanguageClick) {
            this.onTargetLanguageClick()
          }
        })
      }
      .layoutWeight(1)
      .justifyContent(this.centerLanguageSelector ? FlexAlign.Center : FlexAlign.Start)

      // 占位元素，用于居中时平衡返回按钮
      if (this.centerLanguageSelector) {
        Row().width(40).height(40)
      }
    }
    .width('100%')
    .height(LanguageListConstants.HEADER_HEIGHT)
    .padding({
      left: LanguageListConstants.HEADER_LEFT_PADDING,
      right: LanguageListConstants.HEADER_RIGHT_PADDING
    })
    .backgroundColor(this.headerBackgroundColor)
  }
}
