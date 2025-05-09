import { CourseUtil } from 'commonlib';
import { CommonDivider, CommonHeader, CommonLoading } from 'componentlib';
import { DateBarItemModel } from '../models/Index';
import { TimetableCourse } from '../types/Index';
import { TimetableVM } from '../viewModels/TimetableVM';

@Builder
export function timetablePageBuilder() {
  TimetablePage();
}


@ComponentV2
export struct TimetablePage {
  vm: TimetableVM = TimetableVM.instance;

  aboutToAppear(): void {
    this.vm.initTimetable();
  }

  build() {
    NavDestination() {
      CommonHeader({ title: '课程表' });
      this.dateBarBuilder();
      this.courseListBuilder();
    }
    .hideTitleBar(true);
  }

  @Builder
  dateBarBuilder() {
    Column() {
      Text(this.vm.getCurrentMonthLabel()).fontWeight(FontWeight.Medium)
        .margin({ bottom: $r('app.string.margin_s') });
      Row() {
        ForEach(this.vm.dateList, (item: DateBarItemModel, index: number) => {
          Column() {
            Text(item.weekday)
              .fontSize($r('app.string.font_size_12'))
              .fontWeight(FontWeight.Medium)
              .fontColor(this.vm.currentIndex === index ?
              $r('app.color.font_color_level1_invert') :
              $r('app.color.font_color_level1'));
            Text(item.date)
              .fontSize($r('app.string.font_size_10'))
              .fontColor(this.vm.currentIndex === index ?
              $r('app.color.font_color_level1_invert') :
              $r('app.color.font_color_level1'))
              .margin({ bottom: $r('app.string.margin_xs') });
            Row() {
              if (item.hasClass) {
                Row()
                  .width(4)
                  .height(4)
                  .borderRadius($r('app.string.border_radius_capsule'))
                  .backgroundColor(this.vm.currentIndex === index ? $r('app.color.system_color_background_white') :
                  $r('app.color.system_theme_color'));
              }
            }
            .height(4);
          }
          .onClick(() => {
            this.vm.getTimetable(index);
          })
          .backgroundColor(this.vm.currentIndex === index ?
          $r('app.color.system_theme_color') :
          $r('app.color.system_color_background_white'),
          )
          .padding($r('app.string.padding_xs'))
          .borderRadius($r('app.string.border_radius_4'));
        }, (item: DateBarItemModel) => item.date);
      }
      .margin({ top: $r('app.string.margin_l') })
      .width($r('app.string.width_percent_full'))
      .justifyContent(FlexAlign.SpaceAround);
    }
    .alignItems(HorizontalAlign.Start)
    .padding($r('app.string.padding_l'));
  }

  @Builder
  courseListBuilder() {
    Column() {
      if (this.vm.isLoading) {
        CommonLoading();
      } else {
        if (this.vm.selectDayCourses.length) {
          List() {
            ForEach(this.vm.selectDayCourses, (course: TimetableCourse) => {
              this.courseCardBuilder(course);
            }, (course: TimetableCourse, index: number) => index + '_' + course.courseId);
          };
        } else {
          Column() {
            Image($r('app.media.ic_timetable_empty'))
              .width(140)
              .height(140)
              .margin($r('app.string.margin_l'));
            Text('今日暂无排课')
              .fontSize($r('app.string.font_size_14'))
              .fontColor($r('app.color.font_color_level2'));
          }
          .justifyContent(FlexAlign.Center)
          .width($r('app.string.width_percent_full'))
          .height($r('app.string.height_percent_75'))
          .backgroundColor($r('app.color.system_color_background_white'))
          .borderRadius($r('app.string.border_radius_16'));
        }
      }
    }
    .width($r('app.string.width_percent_full'))
    .padding($r('app.string.padding_l'))
    .backgroundColor($r('app.color.system_color_background_auxiliary'))
    .layoutWeight(1);
  }

  @Builder
  courseCardBuilder(course: TimetableCourse) {
    Column() {
      if (course.timetable) {
        Row() {
          Image($r('app.media.ic_bell_clock'))
            .width($r('app.integer.icon_size_24'))
            .height($r('app.integer.icon_size_24'))
            .margin({ right: $r('app.string.margin_s') });
          Text(`${course.timetable.startTime} - ${course.timetable.endTime}`)
            .fontColor($r('app.color.font_color_level1'))
            .layoutWeight(1);
          if (this.vm.showAddButton) {
            Row() {
              if (course.isAddCalendar) {
                Text('已添加日程')
                  .fontColor($r('app.color.font_color_level2'))
                  .fontSize($r('app.string.font_size_14'));
              } else {
                Image($r('app.media.ic_public_plus'))
                  .width($r('app.integer.icon_size_16'))
                  .height($r('app.integer.icon_size_16'))
                  .margin({ right: $r('app.string.margin_s') });

                Text('添加日程')
                  .fontColor($r('app.color.font_color_level1'))
                  .fontSize($r('app.string.font_size_14'));
              }

            }
            .onClick(() => {
              this.vm.addCalendar(course);
            });
          }

        }
        .width($r('app.string.width_percent_full'));

        CommonDivider();

        Row() {
          Column() {
            Image(course.mainDiagram)
              .height(64)
              .aspectRatio(16 / 9)
              .borderRadius($r('app.string.border_radius_4'))
              .margin({ right: $r('app.string.margin_l') });
            Row() {
              Text(CourseUtil.getCourseTypeLabel(course.type))
                .fontSize($r('app.string.font_size_10'))
                .fontColor($r('app.color.font_color_level1_invert'));
            }
            .position({
              left: 0,
              top: 0,
            })
            .borderRadius({
              topLeft: $r('app.string.border_radius_4'),
              bottomRight: $r('app.string.border_radius_8'),
            })
            .padding({
              left: $r('app.string.padding_s'),
              right: $r('app.string.padding_s'),
              top: $r('app.string.padding_xxs'),
              bottom: $r('app.string.padding_xxs'),
            })
            .backgroundColor($r('app.color.system_theme_color'));
          };

          Column() {
            Text(course.name)
              .fontColor($r('app.color.font_color_level1'))
              .fontWeight(FontWeight.Medium);
            Text() {
              Span(course.currentHour.toString())
                .fontColor($r('app.color.system_theme_color'));
              Span(`/${course.classHour}课时`)
                .fontColor($r('app.color.font_color_level2'));
            }
            .fontSize($r('app.string.font_size_12'));
          }
          .height(64)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1);

        }
        .width($r('app.string.width_percent_full'));
      }

    }
    .width($r('app.string.width_percent_full'))
    .backgroundColor($r('app.color.system_color_background_white'))
    .padding($r('app.string.padding_l'))
    .borderRadius($r('app.string.border_radius_16'))
    .justifyContent(FlexAlign.Start);
  }
}
