import { CourseDetailRouterInfo, CourseUtil, FormatUtil, RouterMap, RouterModule, ScheduleConfigUtil } from 'commonlib';
import { ComponentConst } from 'componentlib';
import { CardWrapper } from 'componentlib/src/main/ets/components/CardWrapper';
import { SimpleCourseInfo } from 'network/src/main/ets/models/response/QueryDayCourseResp';

enum CourseState {
  FINISHED,
  TO_ATTEND,
}

@Extend(Text) function activeMiddleTextStyle(active: boolean) {
  .fontColor(active ? Color.White : $r('app.color.system_color_grey_60'))
  .fontSize($r('app.string.font_size_12'))
  .fontWeight(FontWeight.Bold);
}

@Extend(Text) function activeSmallTextStyle(active: boolean) {
  .fontColor(active ? Color.White : $r('app.color.system_color_grey_60'))
  .fontSize($r('app.string.font_size_10'));
}

@ComponentV2
export struct DayCourseInfoCard {
  @Param @Require dateTime: Date;
  @Param @Require courseInfo: SimpleCourseInfo;
  @Local state: CourseState = CourseState.FINISHED;

  aboutToAppear(): void {
    this.updateCourseState();
    // 半分钟刷新一次课程状态
    setInterval(() => {
      this.updateCourseState();
    }, 30000);
  }

  // 根据当前时间和下课时间，计算当前课程状态
  updateCourseState() {
    const endTime = ScheduleConfigUtil.getDayScheduleDate(this.courseInfo.daySchedule, this.dateTime).second;
    const now = new Date();
    this.state = now.getTime() > endTime.getTime() ? CourseState.FINISHED : CourseState.TO_ATTEND;
  }

  build() {
    Row() {
      Circle()
        .width(14)
        .height(14)
        .fill(this.stateColor())

      // 时间段分布
      Column({ space: 4 }) {
        Text(FormatUtil.formatDate(this.dateTime))
          .activeMiddleTextStyle(false)

        Text(ScheduleConfigUtil.getCoursePeriod(this.courseInfo.daySchedule))
          .activeSmallTextStyle(false)

        Text(ScheduleConfigUtil.getDayScheduleTimeString(this.courseInfo.daySchedule))
          .activeSmallTextStyle(false)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: $r('app.string.margin_l') })

      // 课程信息
      Row() {
        CardWrapper({
          bgColor: this.cardBgColor(),
          cardRadius: $r('app.string.border_radius_12'),
        }) {
          RelativeContainer() {
            Text(this.courseInfo.courseName)
              .activeMiddleTextStyle(this.state === CourseState.TO_ATTEND)
              .constraintSize({ maxWidth: '70%' })
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .id('course_name')

            Text() {
              Span($r('app.string.teacher'))
              Span(this.courseInfo.teacher)
            }
            .activeSmallTextStyle(this.state === CourseState.TO_ATTEND)
            .alignRules({ top: ComponentConst.bindBottom('course_name') })
            .margin({ top: $r('app.string.margin_m') })
            .id('course_teacher')

            Text() {
              Span($r('app.string.classroom'))
              Span(this.courseInfo.classroom)
            }
            .activeSmallTextStyle(this.state === CourseState.TO_ATTEND)
            .alignRules({ top: ComponentConst.bindBottom('course_teacher') })
            .margin({ top: $r('app.string.margin_xs') })
            .id('course_classroom')

            Image($r('app.media.ic_notice'))
              .objectFit(ImageFit.Fill)
              .width(36)
              .height(36)
              .alignRules({ right: ComponentConst.bindEnd() })
              .id('notice_icon')
          }
          .width(ComponentConst.FULL_PARENT)
          .height(ComponentConst.AUTO_SIZE)
        }
      }
      .layoutWeight(1)
      .margin({ left: $r('app.string.margin_l') })
      .height(ComponentConst.AUTO_SIZE)
    }
    .alignItems(VerticalAlign.Center)
    .width(ComponentConst.FULL_PARENT)
    .onClick(() => {
      const param: CourseDetailRouterInfo = {
        dateTime: this.dateTime,
        courseInfo: CourseUtil.getCourseDetail(this.courseInfo.courseName),
      };
      RouterModule.push({
        url: RouterMap.COURSE_DETAIL,
        param: param,
      });
    })
  }

  stateColor(): Resource {
    return this.state === CourseState.TO_ATTEND ?
      $r('sys.color.multi_color_09') :
      $r('app.color.system_color_grey_40');
  }

  cardBgColor(): Resource {
    return this.state === CourseState.TO_ATTEND ?
      $r('sys.color.multi_color_09') :
      $r('sys.color.background_secondary');
  }
}