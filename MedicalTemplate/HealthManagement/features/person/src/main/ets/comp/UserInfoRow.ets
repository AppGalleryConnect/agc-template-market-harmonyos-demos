/**
 * @usage: 用于个人信息页面展示用户信息行项。支持左侧主标题和副标题显示，右侧内容展示，包含点击事件和开关切换功能。
 * 关键数据结构包含leftTitle（主标题）、subTitle（副标题）、rightContent（右侧内容）、isSwitch（是否为开关模式）等参数。
 * 包含if逻辑判断是否显示副标题。
 * @layout: 横向排列布局。左侧为纵向排列的Column容器，包含主标题Text和副标题Text（条件显示）。中间为Blank占位符。
 * 右侧为内容Text和箭头图标Image，均右对齐。整体行高48vp，左右内边距12vp。
 * @constraints: leftTitle、subTitle、rightContent参数可定制，rightOnClick和switchButton事件回调可配置，isSwitch开关状态可控制
 * @isGen: true
 * @fileType: component
 * @zhName: 用户信息行组件
 * @subPage: 
 * @component:
 */
@ComponentV2
export struct UserInfoRow {
  @Param leftTitle: string = ''
  @Param subTitle: string = ''
  @Param rightContent: string = ''
  @Event rightOnClick: () => void
  @Event switchButton: (isOn: boolean) => void
  @Param isSwitch: boolean = false

  build() {
    Row() {
      Column({ space: 2 }) {
        Text(this.leftTitle)
          .lineHeight($r('app.float.vp_20'))
        if (this.subTitle) {
          Text(this.subTitle)
            .lineHeight($r('app.float.vp_20'))
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
        }
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
      Text(this.rightContent)
        .lineHeight($r('app.float.vp_20'))
        .textAlign(TextAlign.End)
        .width($r('app.float.vp_120'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Image($r('app.media.iconRight'))
        .size({ width: $r('app.float.vp_24'), height: $r('app.float.vp_24') })
    }
    .onClick(() => {
      if (this.rightOnClick) {
        this.rightOnClick()
      }
    })
    .size({ width: '100%', height: $r('app.float.vp_48') })
    .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })
  }
}