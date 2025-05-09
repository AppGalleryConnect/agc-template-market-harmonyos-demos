import { CourseInfo, CourseStatusMap, CourseUtil } from 'commonlib';
import { CommonHeader, CommonLoading } from 'componentlib';
import { MY_COURSE_TAB_LIST } from '../constants/Constants';
import { MyCourseTabItem } from '../types/Index';
import { MyCoursePageVM } from '../viewModels/MyCoursePageVM';

@Builder
export function myCoursePageBuilder() {
  MyCoursePage();
}

@ComponentV2
export struct MyCoursePage {
  vm: MyCoursePageVM = MyCoursePageVM.instance;

  aboutToAppear(): void {
    this.vm.initCourseList();
  }

  build() {
    NavDestination() {
      CommonHeader({ title: '已购课程' });
      this.courseTabBuilder();
    }
    .hideTitleBar(true);
  }

  @Builder
  courseTabBuilder() {
    Tabs({ barPosition: BarPosition.Start, index: this.vm.currentIndex, controller: this.vm.tabController }) {
      ForEach(MY_COURSE_TAB_LIST, (item: MyCourseTabItem, index: number) => {
        TabContent() {
          Column() {
            if (this.vm.isLoading) {
              CommonLoading();
            } else {
              if (this.vm.courseList.length) {
                List() {
                  ForEach(this.vm.courseList, (item: CourseInfo) => {
                    ListItem() {
                      this.courseCardBuilder(item);
                    };
                  }, (item: CourseInfo) => item.courseId + item.name);
                };

              } else {
                Column() {
                  Image($r('app.media.ic_course_empty'))
                    .width(160)
                    .height(160)
                    .margin({ bottom: $r('app.string.margin_s') });
                  Text('暂无课程')
                    .fontSize($r('app.string.font_size_14'))
                    .fontColor($r('app.color.font_color_level2'));
                  if (this.vm.currentIndex === 0) {
                    Row() {
                      Text('发现好课')
                        .fontColor($r('app.color.font_color_level1_invert'))
                        .fontSize($r('app.string.font_size_14'))
                        .fontWeight(FontWeight.Medium);
                    }
                    .onClick(() => {
                      this.vm.jumpToCourseCenter();
                    })
                    .backgroundColor($r('app.color.system_theme_color'))
                    .justifyContent(FlexAlign.Center)
                    .width($r('app.string.width_percent_75'))
                    .padding({
                      top: $r('app.string.padding_m'),
                      bottom: $r('app.string.padding_m'),
                    })
                    .borderRadius($r('app.string.border_radius_capsule'))
                    .margin({ top: $r('app.string.margin_xl') });
                  }
                }
                .backgroundColor($r('app.color.system_color_background_white'))
                .borderRadius($r('app.string.border_radius_16'))
                .padding($r('app.string.padding_xxl'))
                .width($r('app.string.width_percent_full'));
              }
            }
            Blank().layoutWeight(1);
          }
          .visibility(this.vm.currentIndex === index ? Visibility.Visible : Visibility.Hidden)
          .justifyContent(FlexAlign.Start)
          .padding($r('app.string.padding_l'))
          .layoutWeight(1);
        }
        .tabBar(this.tabBarBuilder(item.label, index))
        .backgroundColor($r('app.color.system_color_background_auxiliary'));
      }, (item: MyCourseTabItem) => item.status + item.label);
    }
    .width($r('app.string.width_percent_full'))
    .vertical(false)
    .barHeight(40)
    .barMode(BarMode.Scrollable)
    .onChange((index: number) => {
      this.vm.initCourseList(index);
    });
  }

  @Builder
  tabBarBuilder(name: string, index: number) {
    Column() {
      Text(name)
        .fontColor(this.vm.currentIndex === index ? $r('app.color.system_theme_color') :
        $r('app.color.font_color_level1'))
        .fontSize($r('app.string.font_size_14'))
        .fontWeight(400)
        .lineHeight(22)
        .margin({ top: $r('app.string.margin_s'), bottom: $r('app.string.margin_s') });
      Divider()
        .strokeWidth(2)
        .width(20)
        .color($r('app.color.system_theme_color'))
        .opacity(this.vm.currentIndex === index ? 1 : 0);
    }
    .backgroundColor($r('app.color.system_color_background_white'))
    .padding({
      left: $r('app.string.padding_xs'),
      right: $r('app.string.padding_xs'),
    })
    .width('40%');
  }

  @Builder
  courseCardBuilder(course: CourseInfo) {
    Row() {
      Image(course.mainDiagram)
        .height(64)
        .aspectRatio(16 / 9)
        .borderRadius($r('app.string.border_radius_4'))
        .margin({ right: $r('app.string.margin_l') });
      Column() {
        Text(course.name)
          .maxLines(1)
          .width($r('app.string.width_percent_75'))
          .textOverflow({ overflow: TextOverflow.Ellipsis });
        Text(`有效期: ${CourseUtil.getExpireLabel(course)}`).classDescStyle();
        Text() {
          Span(course.currentHour.toString())
            .fontColor(course.status === CourseStatusMap.IN_PROGRESS ? $r('app.color.system_theme_color') :
            $r('app.color.font_color_level2'));
          Span(`/${course.classHour}课时`);
        }.classDescStyle();
      }
      .layoutWeight(1)
      .height(64)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text(CourseUtil.getCourseStatusLabel(course.status))
          .fontSize($r('app.string.font_size_10'))
          .fontColor(course.status === CourseStatusMap.IN_PROGRESS ?
          $r('app.color.font_color_level1_invert') :
          $r('app.color.font_color_level2'),
          );
      }
      .position({
        right: -16,
        top: -16,
      })
      .borderRadius({
        bottomLeft: $r('app.string.border_radius_8'),
      })
      .padding({
        left: $r('app.string.padding_s'),
        right: $r('app.string.padding_s'),
        top: $r('app.string.padding_xxs'),
        bottom: $r('app.string.padding_xxs'),
      })
      .backgroundColor(course.status === CourseStatusMap.IN_PROGRESS ?
      $r('app.color.icon_color_success') :
      $r('app.color.system_color_background_shadow'),
      );
    }
    .clip(true)
    .width($r('app.string.width_percent_full'))
    .backgroundColor($r('app.color.system_color_background_white'))
    .margin({ bottom: $r('app.string.margin_l') })
    .borderRadius($r('app.string.border_radius_16'))
    .padding($r('app.string.padding_l'));
  }
}

@Extend(Text)
function classDescStyle() {
  .fontSize($r('app.string.font_size_12'))
  .fontColor($r('app.color.font_color_level2'));
}