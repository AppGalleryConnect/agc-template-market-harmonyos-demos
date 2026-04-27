/**
 * @usage: 用于在列表或页面无数据时展示空状态提示的通用组件。
 * @layout: 组件采用垂直布局（Column），从上到下依次为：空状态图片，提示文字"暂无数据"，内容垂直水平居中。
 * @constraints:
 * @domain: 工具
 * @isGen: true
 * @fileType: component
 * @zhName: 空状态组件
 */
@ComponentV2
export struct EmptyComp {
  build() {
    Column() {
      Image($r('app.media.empty_page_img'))
        .width(160)
        .height(160)
      Text('暂无数据')
        .fontColor('rgba(0, 0, 0, 0.30)')
        .fontSize(14)
    }
    .constraintSize({ minHeight: 180 })
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
  }
}
