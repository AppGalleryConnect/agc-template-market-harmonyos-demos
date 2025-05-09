import { CourseInfo, CourseUtil } from 'commonlib';

@ComponentV2
export struct OrderCard {
  @Param @Require course: CourseInfo;
  @Param cardHeight: number = 100;
  build() {
    Flex() {
      Image(this.course.mainDiagram)
        .width(this.cardHeight)
        .height(this.cardHeight)
        .flexShrink(0)
        .objectFit(ImageFit.Cover)
        .borderRadius($r('app.string.border_radius_8'))
        .margin({right:$r('app.string.margin_l')})
      Column() {
        Text(this.course.name)
          .textOverflow({overflow:TextOverflow.Ellipsis})
          .maxLines(1)
          .fontColor($r('app.color.font_color_level1'))
          .margin({bottom:$r('app.string.margin_s')})
        Text(`有效期: ${CourseUtil.getExpireLabel(this.course)}`)
          .descLabelStyle()
          .lineHeight($r('app.string.margin_l'))
          .margin({bottom:$r('app.string.margin_s')})
        Text(`规格: ${CourseUtil.getClassHourLabel(this.course)}`).descLabelStyle()
      }
      .height(this.cardHeight)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      Column() {
        Text(`¥${this.course.price}`)
          .fontColor($r('app.color.font_color_level2'))
          .fontSize($r('app.string.font_size_14'))
      }
      .width($r('app.string.width_percent_25'))
      .alignItems(HorizontalAlign.End)
    }
    .width($r('app.string.width_percent_full'))
  }
}

@Extend(Text)
function descLabelStyle(){
  .fontColor($r('app.color.font_color_level2'))
    .fontSize($r('app.string.font_size_12'));
}