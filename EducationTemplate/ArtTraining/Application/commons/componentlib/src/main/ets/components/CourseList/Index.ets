import { CourseInfo, CourseTypeMap } from 'commonlib';
import { CommonLoading } from '../CommonLoading/Index';
import { CommonEmptyState } from '../CommonEmptyState/Index';

@Preview
@ComponentV2
struct CourseList {
  // 课程列表
  @Param coursesList: CourseInfo[] = [];
  // 列表展示方向
  @Param isVertical: boolean = true;
  // 展示左上角的标签
  @Param showTag: boolean = true;
  // 图片展示比例
  @Param cardRatio: number = 16 / 9;
  // 标题文字颜色
  @Param titleColor: ResourceColor = $r('app.color.font_color_level1');
  // 标题文字大小
  @Param titleSize: ResourceStr | number = $r('app.string.font_size_16');
  // 课程介绍文字颜色
  @Param descColor: ResourceColor = $r('app.color.font_color_level2');
  // 课程介绍文字大小
  @Param descSize: ResourceStr | number = $r('app.string.font_size_12');
  // 主题颜色
  @Param themeColor: ResourceColor = $r('app.color.system_theme_color');
  // 价格文字大小
  @Param priceSize: ResourceStr | number = $r('app.string.font_size_16');
  // 库存情况文字大小
  @Param sellInfoSize: ResourceStr | number = $r('app.string.font_size_10');
  // 库存情况文字颜色
  @Param sellInfoColor: ResourceColor = $r('app.color.font_color_level3');
  // 加载状态
  @Param isLoading: boolean = false;
  // 卡片点击回调
  @Event handleClick: (course: CourseInfo) => void;

  build() {
    Column() {
      if (this.isLoading) {
        CommonLoading();
      } else if (this.coursesList.length) {
        if (this.isVertical) {
          this.verticalListBuilder();
        } else {
          this.horizontalListBuilder();
        }
      } else {
        CommonEmptyState();
      }
    };
  }

  @Builder
  verticalListBuilder() {
    List({ space: 16 }) {
      ForEach(this.coursesList, (course: CourseInfo, index: number) => {
        ListItem() {
          this.courseCardBuilder(course, index);
        };
      }, (item: CourseInfo, index: number) => index + JSON.stringify(item));
    }
    .scrollBar(BarState.Off);
  }

  @Builder
  horizontalListBuilder() {
    List({ space: 16 }) {
      ForEach(this.coursesList, (course: CourseInfo, index: number) => {
        ListItem() {
          this.courseCardBuilder(course, index);
        }
        .width($r('app.string.width_percent_75'));
      }, (item: CourseInfo, index: number) => index + JSON.stringify(item));
    }
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal);
  }

  @Builder
  courseCardBuilder(course: CourseInfo, index: number) {
    Column() {
      Image(course.mainDiagram)
        .width($r('app.string.width_percent_full'))
        .aspectRatio(this.cardRatio);

      Column() {
        Text(course.name)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(this.titleSize)
          .fontColor(this.titleColor)
          .margin({ bottom: $r('app.string.margin_s') });

        Text(course.summary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(this.descSize)
          .fontColor(this.descColor)
          .margin({ bottom: $r('app.string.margin_xs') });

        Row() {
          Text() {
            Span('¥ ')
              .fontSize(this.descSize);
            Span(course.price.toString())
              .fontSize(this.priceSize);
          }
          .fontColor(this.themeColor)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1);

          Text('立即购买')
            .fontSize($r('app.string.font_size_12'))
            .fontWeight(500)
            .fontColor($r('app.color.font_color_level1_invert'))
            .backgroundColor($r('app.color.system_theme_color'))
            .borderRadius($r('app.string.padding_l'))
            .padding({
              top: $r('app.string.padding_s'),
              bottom: $r('app.string.padding_s'),
              left: $r('app.string.padding_m'),
              right: $r('app.string.padding_m'),
            });
        }
        .margin({ top: $r('app.string.margin_s') });
      }
      .alignItems(HorizontalAlign.Start)
      .padding($r('app.string.padding_m'))
      .width($r('app.string.width_percent_full'));

      if (this.showTag) {
        Row() {
          Image(course.type === CourseTypeMap.ONLINE ?
          $r('app.media.ic_course_online') :
          $r('app.media.ic_course_offline'))
            .width(36)
            .height(16);
        }
        .position({
          left: 0,
          top: 0,
        })
        .borderRadius({
          topLeft: $r('app.string.border_radius_4'),
          bottomRight: $r('app.string.border_radius_8'),
        });
      }
    }
    .backgroundColor($r('app.color.system_color_background_white'))
    .clip(true)
    .borderRadius($r('app.string.border_radius_16'))
    .margin({
      left: index === 0 && !this.isVertical ? $r('app.string.margin_l') : 0,
      right: index === this.coursesList.length - 1 && !this.isVertical ? $r('app.string.margin_l') : 0,
      bottom: this.isVertical ? 0 : $r('app.string.margin_s'),
    })
    .shadow({
      radius: 10,
      color: $r('app.color.system_color_background_shadow'),
      offsetX: 0,
      offsetY: 10,
    })
    .onClick(() => {
      this.handleClick?.(course);
    });
  }
}

export { CourseList };