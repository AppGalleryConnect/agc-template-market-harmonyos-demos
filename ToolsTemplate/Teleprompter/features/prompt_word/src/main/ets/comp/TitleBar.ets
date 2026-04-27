/**
 * @usage: 用于在页面中展示区域标题的通用组件，支持左右两侧自定义内容。关键数据结构：leftBuilder（左侧自定义构建器BuilderParam）,
 * rightBuilder（右侧自定义构建器BuilderParam）。包含条件渲染：判断是否显示左侧,或右侧自定义内容。
 * @layout: 组件采用横向布局（Row），从左到右分为两部分，两端对齐（SpaceBetween）：左侧为标题区域，包含标题标记图标Image和标题文字。
 * 如果有leftBuilder则在标题右侧显示自定义内容。右侧为自定义区域，如果有rightBuilder则显示自定义内容。内容底部对齐。
 * @constraints:
 * @domain: 工具
 * @isGen: true
 * @fileType: component
 * @zhName: 标题栏组件
 * @image: screenshots/prompt_word/TitleBar.jpg
 */

@ComponentV2
export struct TitleBar {
  @Param title: string | Resource = '';
  @BuilderParam rightBuilder?: () => void;
  @BuilderParam leftBuilder?: () => void;

  build() {
    Row() {
      Row({ space: 10 }) {
        Row({ space: 8 }) {
          Image($r('app.media.title_mark_icon'))
            .width(3)
            .height(18)
          Text(this.title)
            .fontSize(18)
            .fontColor('rgba(0, 0, 0, 0.90)')
            .fontFamily('HarmonyOS_Sans_SC_Medium')
        }

        if (this.leftBuilder) {
          this.leftBuilder()
        }
      }

      if (this.rightBuilder) {
        this.rightBuilder()
      }
    }
    .alignItems(VerticalAlign.Bottom)
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
  }
}
