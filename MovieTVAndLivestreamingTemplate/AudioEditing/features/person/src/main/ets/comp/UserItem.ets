/**
 * @usage: 个人中心功能列表项组件,用于个人中心页面展示各功能入口,如个人信息、VIP会员、设置等。
 * 展示功能标题、消息数量徽章和右箭头。根据index和listLength参数自动设置圆角。
 * @layout: 采用Row横向布局,左侧为标题文字,中间为Blank占位,右侧为消息数量徽章(可选)和右箭头图标。
 * 顶部和底部列表项带圆角。
 * @constraints: 必须提供title参数。messageNum大于0时显示徽章,超过99显示99+。
 * @domain: 音频编辑
 * @zhName: 个人中心列表项
 * @isGen: true
 * @fileType: component
 * @image: 
 */
@ComponentV2
export struct UserItem {
  @Param title: string = ''
  @Param url: string = ''
  @Param @Once messageNum: number = 0
  @Param isGrid: boolean = false
  @Param listLength: number = 1
  @Param index: number = 0



  build() {
    Row() {
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
      .margin({ left: 12 })
    }
    .padding({
      top: 12,
      bottom: 12,
      right: 12,
    })
    .height(56)
    .margin({bottom : this.isGrid ? 16 : 0})
    .borderRadius({topLeft: this.index === 0 ? 16 : 0,
      topRight: this.index === 0 ? 16 : 0,
      bottomLeft: this.index === this.listLength - 1 ? 16 : 0,
      bottomRight: this.index === this.listLength - 1 ? 16 : 0,
    })
    .backgroundColor('#FFFFFF')
    .alignItems(VerticalAlign.Center)
  }
}