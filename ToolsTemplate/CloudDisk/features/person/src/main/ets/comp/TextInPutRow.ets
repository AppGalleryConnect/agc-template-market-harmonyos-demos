import { Constants } from 'common'

/**
 * @usage: 用于表单输入场景。提供标题和文本输入框的横向布局，适用于个人信息编辑等场景。
 * 关键数据结构：title（标题字符串或资源）、content（输入内容字符串）、placeHolder（占位符字符串或资源）、
 * blockContent（输入回调函数，参数为输入的文本）。
 * @layout: 横向布局。左侧为标题（固定宽度72，左对齐），右侧为文本输入框（占据剩余空间，透明背景）。
 * 整体高度60，垂直居中对齐。
 * @constraints: title标题不能为空，blockContent回调函数必须正确处理输入的文本
 * @isGen: true
 * @fileType: component
 * @zhName: 文本输入行组件
 */
@ComponentV2
export struct TextInPutRow {
  @Param title: string | Resource = ''
  @Local content: string = ''
  @Param placeHolder: string | Resource = ''
  @Event blockContent: (value: string) => void

  build() {
    Row({ space: 10 }) {
      Text(this.title)
        .font({
          size: 15,
          weight: 500
        })
        .width(72)
        .fontColor($r('app.color.dark_color_444444'))
        .textAlign(TextAlign.Start)
        .height(18)

      TextInput({ placeholder: this.placeHolder, text: this.content })
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({
          size: $r('sys.float.Body_L'),
          weight: 400
        })
        .layoutWeight(1)
        .fontSize(14)
        .fontWeight(400)
        .height(44)
        .fontColor($r('app.color.dark_color_444444'))
        .type(InputType.Normal)
        .backgroundColor(Color.Transparent)
        .onChange((value: string) => {
          if (this.blockContent) {
            this.content = value
            this.blockContent(value)
          }
        })
    }
    .padding({ left: 12, right: 12 })
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .width(Constants.FULL_SIZE)
    .height(60)

  }
}
