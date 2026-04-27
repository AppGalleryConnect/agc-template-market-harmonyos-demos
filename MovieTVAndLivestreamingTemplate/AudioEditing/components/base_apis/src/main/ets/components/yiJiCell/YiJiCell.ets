import { TextStyleModifier } from './Style'

@ComponentV2
export struct YiJiCell {
  /**
   * 宜文本
   */
  @Param yiText: string[] = []
  /**
   * 忌文本
   */
  @Param jiText: string[] = []
  /**
   * 宜图标
   */
  @Param yiIcon: ResourceStr = $r('app.media.ic_yi_str')
  /**
   * 忌图标
   */
  @Param jiIcon: ResourceStr = $r('app.media.ic_ji_str')
  /**
   * 文本是否省略号展示
   */
  @Param isEllipsis: boolean = true
  /**
   * 单元格点击事件
   */
  @Event onYiJiCellClick: () => void = () => {}

  build() {
    Column() {
      Row() {
        Image(this.yiIcon)
          .width(22)
          .margin({ right: 12 });

        Text() {
          ForEach(this.yiText, (value: string) => {
            Span(value + '  ')
          },(value: string) => value)
        }
        .lineHeight(24)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_S'))
        .fontColor(FontWeight.Regular)
        .layoutWeight(1)
        .attributeModifier(new TextStyleModifier(this.isEllipsis))

      }
      .margin({ top: 16, bottom: 16 })

      Row() {
        Image(this.jiIcon)
          .width(22)
          .margin({ right: 12 });

        Text() {
          ForEach(this.jiText, (value: string) => {
            Span(value + '  ')
          },(value: string) => value)
        }
        .lineHeight(24)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_S'))
        .fontColor(FontWeight.Regular)
        .layoutWeight(1)
        .attributeModifier(new TextStyleModifier(this.isEllipsis))
      }
      .margin({ bottom: 9 })
    }
    .onClick(() => {
      this.onYiJiCellClick()
    })
  }
}