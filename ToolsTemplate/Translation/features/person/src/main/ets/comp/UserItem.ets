/**
 * @usage: 用户菜单项组件，展示菜单项标题、图标和消息数量角标。用于个人中心的功能菜单列表。
 * 主要数据结构包括title（标题）、image（图标）、messageNum（消息数量）。包含if逻辑判断图标和消息角标显示。
 * @layout: 组件采用Row横向布局。左侧为图标Image（可选），右侧Row包含标题Text、消息角标Text（可选）和箭头图标Image。
 * @constraints: 无
 * @isGen: true
 * @domain: 翻译工具
 * @zhName: 用户菜单项组件
 * @fileType: component
 * @image:
 */
@ComponentV2
export struct UserItem {
  @Param title: string = ''
  @Param image: ResourceStr = ''
  @Param url: string = ''
  @Param isLine: boolean = true
  @Param @Once messageNum: number = 0

  build() {
    Row() {
      if (this.image) {
        Image(this.image)
          .size({ width: 24, height: 24 })
          .fillColor($r('sys.color.font_primary'))
          .draggable(false)
      }
      Row() {
        Text(this.title)
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))

        Blank()
        if (this.messageNum > 0) {
          Text(this.messageNum > 99 ? '99+' : this.messageNum.toString())
            .textAlign(TextAlign.Center)
            .backgroundColor($r('sys.color.warning'))
            .borderRadius(8)
            .size({ width: 30, height: 16 })
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize(10)
            .fontWeight(400)
            .margin({ right: 4 })
        }
        Image($r('app.media.iconRight'))
          .size({ width: 18, height: 18 })
      }
      .layoutWeight(1)
      .margin({ left: this.image ? 16 : 0 })
    }
    .padding({
      top: 12,
      bottom: 12,
      left: 8,
      right: 8,
    })
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .alignItems(VerticalAlign.Center)
  }
}