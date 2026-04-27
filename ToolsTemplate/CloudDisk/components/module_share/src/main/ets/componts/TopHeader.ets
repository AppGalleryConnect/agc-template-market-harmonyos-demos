import { PopViewUtils } from '../utils/PopViewUtils'

/**
 * @usage: 用于弹窗顶部标题栏场景。提供返回按钮、标题和关闭按钮的横向布局。
 * 关键数据结构：title（标题字符串或资源）、PopViewUtils（弹窗工具类，提供closeSheet关闭弹窗方法）。
 * @layout: 横向布局。左侧为返回按钮（20x20），中间为标题文字（居中），右侧为关闭按钮（20x20）。
 * 整体高度20，两端对齐，垂直居中。
 * @constraints: title标题不能为空，PopViewUtils必须正确初始化
 * @isGen: true
 * @fileType: component
 * @zhName: 顶部标题栏组件
 */
@ComponentV2
export struct TopHeader {
  @Param title: string | Resource = ''

  build() {
    Row() {
      Image($r('app.media.set_code_Back'))
        .onClick(() => {
          PopViewUtils.closeSheet()
        })
        .width(20)
        .height(20)
      Text(this.title)
        .font({
          size: 16,
          weight: 500
        })
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
      Image($r('app.media.set_code_close'))
        .onClick(() => {
          PopViewUtils.closeSheet()
        })
        .width(20)
        .height(20)
    }
    .width('100%')
    .height(20)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}