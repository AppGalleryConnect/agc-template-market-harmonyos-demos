/**
 * @usage: 用户菜单项组件，用于显示个人中心的菜单选项。主要数据结构包括title（标题）、image（图标）、
 * url（跳转链接）、isLine（是否显示分割线）、messageNum（消息数量）等关键数据。用于构建个人中心的设置项列表。
 * @layout: 行布局（Row），从左到右依次为：左侧图标Image、内容Row（包含标题Text和右箭头Image）。
 * 内容Row采用水平布局，标题和箭头之间使用SpaceBetween对齐。
 * @constraints:
 * @domain: 健康医疗
 * @zhName: 用户菜单项组件
 * @isGen: true
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
      Image(this.image)
        .size({ width: $r('app.float.vp_24'), height: $r('app.float.vp_24') })
        .fillColor($r('sys.color.font_primary'))
        .draggable(false)
      Row() {
        Text(this.title)
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))

        Image($r('app.media.iconRight'))
          .size({ width: $r('app.float.vp_18'), height: $r('app.float.vp_18') })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ left: $r('app.float.vp_16') })
    }
    .padding({
      top: $r('app.float.vp_12'),
      bottom: $r('app.float.vp_12'),
      left: $r('app.float.vp_8'),
      right: $r('app.float.vp_8'),
    })
  }
}