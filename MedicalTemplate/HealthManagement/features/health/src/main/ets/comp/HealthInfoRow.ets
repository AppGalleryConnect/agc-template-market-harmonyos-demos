/**
 * @usage: 健康信息行组件，用于展示和输入健康数据如体重、腰围等信息。主要数据结构包括titleName（标题名称）、titleValue（标题值）、
 * placeholder（占位符文本）等参数。支持文本输入和显示功能。
 * @layout: 横向排列布局（Row），从左到右依次为：左侧空白Blank、标题Text、输入框TextInput（占据剩余空间）、右侧箭头图标Image、
 * 右侧空白Blank。整体行高60vp。
 * @constraints: titleName、titleValue、placeholder参数必须提供且为ResourceStr或string类型，输入框设置为只读模式，
 * 箭头图标尺寸固定。
 * @isGen: true
 * @fileType: component
 * @zhName: 健康信息行组件
 */
@ComponentV2
export struct HealthInfoRow {
  @Param @Require titleName: ResourceStr;
  @Param @Require titleValue: string;
  @Param @Require placeholder: ResourceStr;

  build() {
    Row() {
      Blank().width($r('app.float.vp_16'))

      Text(this.titleName)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.Black)

      TextInput({
        text: this.titleValue,
        placeholder: this.placeholder
      })
        .type(InputType.Normal)
        .layoutWeight(1)
        .fontSize($r('sys.float.Body_L'))
        .fontColor(Color.Black)
        .placeholderFont({ size: $r('sys.float.Body_L') })
        .placeholderColor($r('sys.color.font_secondary'))
        .backgroundColor(Color.Transparent)
        .textAlign(TextAlign.End)
        .padding({ right: $r('app.float.vp_4') })
        .hitTestBehavior(HitTestMode.None)

      Image($r('app.media.iconRight'))
        .size({ width: $r('app.float.vp_20'), height: $r('app.float.vp_20') })

      Blank().width($r('app.float.vp_10'))
    }
    .size({ width: '100%', height: $r('app.float.vp_60') })
  }
}