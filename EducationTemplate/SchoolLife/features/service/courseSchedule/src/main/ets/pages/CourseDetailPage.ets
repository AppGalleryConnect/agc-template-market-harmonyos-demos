import {
  AccountUtil,
  CourseDetail,
  CourseDetailRouterInfo,
  FormatUtil, RouterMap, RouterModule, ScheduleConfigUtil, ScheduleFlag } from 'commonlib';
import { CardWrapper, ComponentConst, NavigateBar } from 'componentlib';
import { promptAction } from '@kit.ArkUI';

@Extend(Divider) function verticalDividerStyle() {
  .strokeWidth(1)
  .width(ComponentConst.FULL_PARENT)
  .color($r('app.color.system_color_grey_20'));
}

@Builder
export function courseDetailPageBuilder() {
  NavDestination() {
    CourseDetailPage()
  }
  .hideTitleBar(true)
  .hideToolBar(true)
}

@ComponentV2
struct CourseDetailPage {
  @Consumer('mainTabController') mainTabController: TabsController = new TabsController();
  @Local dateTime?: Date;
  @Local courseInfo?: CourseDetail;

  aboutToAppear(): void {
    const param: CourseDetailRouterInfo | undefined = RouterModule.getNavParam({
      url: RouterMap.COURSE_DETAIL,
    });
    this.dateTime = param?.dateTime;
    this.courseInfo = param?.courseInfo;
  }

  build() {
    Stack() {
      // 背景渐变
      Column()
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [$r('sys.color.multi_color_09'), 0.0],
            [$r('sys.color.background_secondary'), 1.0],
          ],
        })
        .width(ComponentConst.FULL_PARENT)
        .height('25%')

      Column({ space: ComponentConst.CARD_SPACE_LARGE }) {
        // 标题
        NavigateBar({ title: $r('app.string.course_detail'), enableBackward: true })

        Scroll() {
          Column({ space: ComponentConst.CARD_SPACE_LARGE }) {
            // 课程信息
            this.courseInfoBuilder();

            // 教师信息
            this.teacherInfoBuilder();

            // 签到按钮
            Button() {
              Text($r('app.string.go_to_sign'))
                .fontSize($r('sys.float.Body_M'))
                .fontColor(Color.White)
            }
            .backgroundColor($r('sys.color.multi_color_09'))
            .width(ComponentConst.FULL_PARENT)
            .height(40)
            .padding({
              top: $r('app.string.padding_xs'),
              bottom: $r('app.string.padding_xs'),
            })
            .onClick(() => {
              if (AccountUtil.getUserInfo().avatar) {
                RouterModule.push({ url: RouterMap.CLASS_SIGN_IN });
              } else {
                RouterModule.getStack().clear(false);
                this.mainTabController.changeIndex(1);
                promptAction.showToast({
                  message: '签到功能需关联华为账号',
                });
              }
            })
          }
          .alignItems(HorizontalAlign.Start)
          .width(ComponentConst.FULL_PARENT)
          .height(ComponentConst.AUTO_SIZE)
          .padding({
            top: ComponentConst.PAGE_VERTICAL_PADDING,
            bottom: ComponentConst.PAGE_VERTICAL_PADDING,
            left: ComponentConst.PAGE_HORIZONTAL_PADDING,
            right: ComponentConst.PAGE_HORIZONTAL_PADDING,
          })
        }
        .scrollBar(BarState.Off)
        .align(Alignment.TopStart)
        .width(ComponentConst.FULL_PARENT)
        .layoutWeight(1)
      }
      .alignItems(HorizontalAlign.Start)
      .width(ComponentConst.FULL_PARENT)
      .height(ComponentConst.FULL_PARENT)
    }
    .alignContent(Alignment.TopStart)
    .width(ComponentConst.FULL_PARENT)
    .height(ComponentConst.FULL_PARENT)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder courseInfoBuilder() {
    CardWrapper() {
      RelativeContainer() {
        Text(this.courseInfo?.courseName)
          .fontSize($r('app.string.font_size_16'))
          .id('course_name')

        Button({ type: ButtonType.Capsule }) {
          Text($r('app.string.course_no_sign'))
            .fontSize($r('app.string.font_size_10'))
            .fontColor(Color.White)
        }
        .padding({
          top: 1,
          bottom: 1,
          left: 6,
          right: 6,
        })
        .backgroundColor($r('app.color.need_sign_state_color'))
        .alignRules({
          center: ComponentConst.bindVerticalCenter('course_name'),
          right: ComponentConst.bindEnd(),
        })
        .visibility(Visibility.None)

        Text(FormatUtil.formatDate(this.dateTime ?? new Date(), '-'))
          .fontSize($r('app.string.font_size_12'))
          .fontColor($r('app.color.system_color_grey_60'))
          .alignRules({
            top: ComponentConst.bindBottom('course_name'),
          })
          .margin({ top: $r('app.string.margin_xs') })
          .id('course_date')

        Divider().verticalDividerStyle()
          .alignRules({
            top: ComponentConst.bindBottom('course_date'),
          })
          .margin({ top: $r('app.string.margin_m') })
          .id('divide_line')

        Row({ space: 9 }) {
          Image($r('app.media.ic_course_date'))
            .objectFit(ImageFit.Fill)
            .size(ComponentConst.ICON_SIZE_S)

          Text() {
            Span($r(`app.string.week_${this.courseInfo?.weekDay ?? 1}`))
            if (this.courseInfo?.scheduleFlag !== ScheduleFlag.NORMAL) {
              Span(this.courseInfo?.scheduleFlag === ScheduleFlag.ODD_WEEK ? $r('app.string.odd_week') : $r('app.string.even_week'))
            } else {
              Span(' ')
            }
            Span(ScheduleConfigUtil.getDayScheduleTimeString(this.courseInfo?.daySchedule ?? []))
          }
          .fontSize($r('app.string.font_size_12'))
          .fontColor($r('app.color.system_color_grey_60'))
        }
        .width(ComponentConst.FULL_PARENT)
        .alignRules({ top: ComponentConst.bindBottom('divide_line') })
        .margin({ top: $r('app.string.margin_m') })
        .id('course_time_info')

        Row({ space: 9 }) {
          Image($r('app.media.ic_course_classroom'))
            .objectFit(ImageFit.Fill)
            .size(ComponentConst.ICON_SIZE_S)

          Text(this.courseInfo?.classroom)
            .fontSize($r('app.string.font_size_12'))
            .fontColor($r('app.color.system_color_grey_60'))
        }
        .width(ComponentConst.FULL_PARENT)
        .alignRules({ top: ComponentConst.bindBottom('course_time_info') })
        .margin({ top: $r('app.string.margin_m') })
        .id('course_classroom_info')
      }
      .width(ComponentConst.FULL_PARENT)
      .height(ComponentConst.AUTO_SIZE)
    }
  }

  @Builder teacherInfoBuilder() {
    CardWrapper() {
      Column() {
        Text($r('app.string.course_teacher'))
          .fontSize($r('app.string.font_size_16'))
          .fontWeight(FontWeight.Bold)

        Divider().verticalDividerStyle()
          .margin({ top: $r('app.string.margin_m') })

        Row() {
          Image($r('app.media.ic_teacher_default_img'))
            .objectFit(ImageFit.Fill)
            .size(ComponentConst.ICON_SIZE_M)

          Column() {
            Text(this.courseInfo?.teacher)
              .fontSize($r('sys.float.Body_M'))

            Row() {
              Image($r('app.media.ic_teacher_position'))
                .objectFit(ImageFit.Fill)
                .size(ComponentConst.ICON_SIZE_S)

              Text('副教授')
                .fontSize($r('app.string.font_size_10'))
                .fontColor($r('app.color.system_color_grey_60'))
                .margin({ left: $r('app.string.margin_xs') })
            }
            .backgroundColor($r('app.color.system_color_grey_5'))
            .margin({ top: $r('app.string.margin_s') })
            .padding({
              top: 2,
              bottom: 2,
              right: $r('app.string.padding_xs'),
            })
            .width(ComponentConst.AUTO_SIZE)
            .height(18)
            .borderRadius(9)
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: $r('app.string.margin_xs') })
          .width(ComponentConst.FULL_PARENT)
          .height(ComponentConst.AUTO_SIZE)
        }
        .alignItems(VerticalAlign.Center)
        .margin({ top: $r('app.string.margin_m') })
        .width(ComponentConst.FULL_PARENT)
        .height(ComponentConst.AUTO_SIZE)
      }
      .alignItems(HorizontalAlign.Start)
      .width(ComponentConst.FULL_PARENT)
      .height(ComponentConst.AUTO_SIZE)
    }
  }
}