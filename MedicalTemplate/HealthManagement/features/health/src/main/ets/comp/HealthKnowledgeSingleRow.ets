import { HealthKnowledgeSingleModel } from '../viewmodel/HealthKnowledgeSingleModel';

/**
 * @usage: 健康知识单项列表组件，用于展示单个健康知识条目。主要数据结构包括HealthKnowledgeSingleModel（健康知识单项模型），
 * 包含img（图片）、title（标题）、subTitle（副标题）等关键数据。包含if逻辑根据标题长度显示不同的文本样式。
 * @layout: 堆叠布局（Stack），底层为背景图片Image，上层为文本内容Column。
 * 文本区域包含标题Text和副标题Text，采用垂直居中、左对齐布局。整体高度90，宽度100%。
 * @constraints: HealthKnowledgeSingleModel数据模型必须提供，图片资源必须存在，组件尺寸固定，文本颜色和字体样式固定。
 * @isGen: true
 * @fileType: component
 * @zhName: 健康知识单项行组件
 */
@ComponentV2
export struct HealthKnowledgeSingleRow {
  @Param @Require knowledgeSingleModelVM: HealthKnowledgeSingleModel;

  build() {
    Stack() {
      Image(this.knowledgeSingleModelVM.img)
        .objectFit(ImageFit.Fill)
        .width('100%')
        .height('100%')

      Column() {
        if (this.knowledgeSingleModelVM.title?.length > 0) {
          Text(this.knowledgeSingleModelVM.title)
            .fontColor($r('app.color.color_352200'))
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Medium)
            .lineHeight($r('app.float.vp_28'))

          Text(this.knowledgeSingleModelVM.subTitle)
            .fontColor($r('app.color.color_352200'))
            .fontSize($r('sys.float.Body_S'))
            .lineHeight($r('app.float.vp_18'))
        } else {
          Text(this.knowledgeSingleModelVM.subTitle)
            .fontColor($r('app.color.color_010B17'))
            .fontSize($r('sys.float.Body_M'))
            .maxLines(2)
            .fontWeight(FontWeight.Medium)
            .lineHeight($r('app.float.vp_22'))
        }
      }
      .width('100%')
      .height('100%')
      .padding({
        left:$r('app.float.vp_24'),
        right: $r('app.float.vp_24')
      })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height($r('app.float.vp_90'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .clip(true)
  }
}