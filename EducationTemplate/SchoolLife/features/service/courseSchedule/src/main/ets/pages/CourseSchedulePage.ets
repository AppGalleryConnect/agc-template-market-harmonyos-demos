import { AppStorageV2 } from '@kit.ArkUI';
import { DialogType, TypePicker, UICalendarPicker } from '@hw-agconnect/ui-calendar-picker';
import { AllCourseInfo, AppStorageMap,
  CourseDetail,
  CourseDetailRouterInfo,
  CourseUtil, RouterMap, RouterModule, ScheduleConfigUtil } from 'commonlib';
import { ScheduleInfo, TimeInfo, UIScheduleFlow } from '@hw-agconnect/ui-schedule-flow';
import { ComponentConst, NavigateBar } from 'componentlib';
import { mappedCourseDetailList } from '../mapper/DataMapper';

@Builder
export function courseSchedulePageBuilder() {
  NavDestination() {
    CourseSchedulePage()
  }
  .hideTitleBar(true)
  .hideToolBar(true)
}

@ComponentV2
struct CourseSchedulePage {
  @Local message: string = 'Hello CourseSchedulePage';
  @Local allCourseInfo: AllCourseInfo = AppStorageV2.connect(
    AllCourseInfo,
    AppStorageMap.ALL_COURSE_INFO,
    () => new AllCourseInfo()
  )!;
  @Local selectedDateTime: Date = new Date();
  @Local semesterStartTime: Date = new Date();
  @Local semesterEndTime: Date = new Date();

  @Computed get allScheduleInfo() {
    return this.allCourseInfo.studentNo !== '' ? mappedCourseDetailList(CourseUtil.getWeekCourseInfo(this.selectedDateTime)) : [];
  }

  @Computed get currentWeek() {
    return ScheduleConfigUtil.getCurrentWeek(this.selectedDateTime);
  }

  @Computed get weekRange(): string {
    return ScheduleConfigUtil.getWeekRangeString(this.selectedDateTime);
  }

  aboutToAppear(): void {
    const timePair = ScheduleConfigUtil.getSemesterTimeRange();
    this.semesterStartTime = timePair.first;
    this.semesterEndTime = timePair.second;
  }

  build() {
    Column() {
      NavigateBar({ title: $r('app.string.course_center'), enableBackward: true })

      Divider().strokeWidth(1)
        .color($r('sys.color.background_secondary'))
        .width(ComponentConst.FULL_PARENT)

      // 日期展示
      this.dateRangeBuilder();


      Divider().strokeWidth(0.5)
        .color($r('sys.color.background_secondary'))
        .width(ComponentConst.FULL_PARENT)

      // 课表展示组件
      Row() {
        UIScheduleFlow({
          currentDate: new Date(),
          scheduleWeek: [
            ScheduleConfigUtil.getWeekRange(this.selectedDateTime).first,
            ScheduleConfigUtil.getWeekRange(this.selectedDateTime).second,
          ],
          divideTimes: [
            new TimeInfo(ScheduleConfigUtil.getDivideTime(), $r('app.string.am')),
            new TimeInfo(ScheduleConfigUtil.getDayScheduleMax(), $r('app.string.pm')),
          ],
          scheduleMaxIndex: ScheduleConfigUtil.getDayScheduleMax(),
          scheduleList: this.allScheduleInfo,
          scheduleClick: (scheduleInfo: ScheduleInfo) => {
            const courseDetail = this.allCourseInfo.courseInfoList
              .find((courseDetail: CourseDetail) => scheduleInfo.scheduleName.startsWith(courseDetail.courseName));
            if (courseDetail === undefined) {
              return;
            }
            const scheduleDate = ScheduleConfigUtil.getWeekRange(this.selectedDateTime).first;
            scheduleDate.setDate(scheduleDate.getDate() + courseDetail.weekDay - 1);

            const param: CourseDetailRouterInfo = {
              dateTime: scheduleDate,
              courseInfo: courseDetail,
            };
            RouterModule.push({
              url: RouterMap.COURSE_DETAIL,
              param: param,
            });
          },
        })
      }
      .width(ComponentConst.FULL_PARENT)
      .layoutWeight(1)
    }
    .height(ComponentConst.FULL_PARENT)
    .width(ComponentConst.FULL_PARENT)
    .backgroundColor(Color.White)
  }

  @Builder dateRangeBuilder() {
    Row() {
      Column() {
        Text() {
          Span('第')
          Span(`${this.currentWeek}`)
          Span('周')
        }
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.multi_color_09'))

        Text(this.weekRange)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('app.color.system_color_grey_60'))
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .height(ComponentConst.AUTO_SIZE)

      Blank()

      Row() {
        UICalendarPicker({
          selected: new Date(),
          type: TypePicker.SINGLE,
          dialogType: DialogType.SHEET,
          startDayOfWeek: 1,
          rangeLimit: [this.semesterStartTime, this.semesterEndTime],
          customColor: $r('sys.color.multi_color_09'),
          onSelected: (selectedDate) => {
            if (selectedDate instanceof Date) {
              animateTo(ComponentConst.animationLinearOutSlowIn, () => {
                this.selectedDateTime = selectedDate;
              });
            }
          },
        }) {
          Column() {
            Image($r('app.media.ic_small_calendar_white'))
              .objectFit(ImageFit.Fill)
              .size({ width: 14, height: 14 })
          }
          .justifyContent(FlexAlign.Center)
          .size(ComponentConst.ICON_SIZE_XS)
          .backgroundColor($r('sys.color.multi_color_09'))
          .borderRadius(12)
        }
      }
    }
    .width(ComponentConst.FULL_PARENT)
    .height(ComponentConst.AUTO_SIZE)
    .padding({
      top: $r('app.string.padding_xm'),
      bottom: $r('app.string.padding_xs'),
      left: ComponentConst.PAGE_HORIZONTAL_PADDING,
      right: ComponentConst.PAGE_HORIZONTAL_PADDING,
    })
  }
}