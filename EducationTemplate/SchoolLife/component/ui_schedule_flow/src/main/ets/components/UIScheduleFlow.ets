import { componentUtils } from '@kit.ArkUI';
import { ComponentConst } from 'componentlib';
import { ColorUtil } from '../util/ColorUtil';
import { pad, ScheduleConfigUtil, NumberUtil } from 'commonlib';

// 分割时间段下标信息（数组）
export class TimeInfo {
  divideTime: number = 0; //分割下标
  periodName: string | Resource = ''; // 分割标题

  constructor(divideTime: number, periodName: string | Resource) {
    this.divideTime = divideTime;
    this.periodName = periodName;
  }
}

// 日程信息数据结构设计
export class ScheduleInfo {
  daySchedule: number[] = []; // 日程时间段，长度为2
  weekDay: number = 0; // 日程所在日期
  scheduleName: string = ''; // 日程名称

  constructor(daySchedule: number[], weekDay: number, scheduleName: string) {
    this.daySchedule = daySchedule;
    this.weekDay = weekDay;
    this.scheduleName = scheduleName;
  }
}

@Extend(Column) function verticalCapsule() {
  .width(24)
  .height(43)
  .backgroundColor($r('sys.color.background_secondary'))
  .borderRadius(12)
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center);
}

enum DrawStep {
  NONE, // 可绘制 顶部月份 和 日程下标
  VERTICAL_GUIDELINE, // 可绘制 需要参照guideline的组件(顶部日期 和 日程信息)
}

@ComponentV2
export struct UIScheduleFlow {
  @Param @Require currentDate: Date; // 选中日期
  @Param @Require scheduleWeek: Date[]; // 日期所在周时间段,长度为2
  @Param @Require divideTimes: TimeInfo[]; // 分割时间段下标信息（数组）
  @Param @Require scheduleMaxIndex: number; // 日程时间段数量
  @Param @Require scheduleList: ScheduleInfo[]; // 日程信息数据结构设计
  @Param scheduleClick?: (scheduleInfo: ScheduleInfo) => void = undefined; // 日程信息数据结构设计

  @Local horizontalPadding: number = ComponentConst.PAGE_HORIZONTAL_PADDING;
  @Local verticalPadding: number = 8;
  @Local verticalGuidelines: GuideLineStyle[] = []; // 顶部日程分布
  @Local drawStep: DrawStep = DrawStep.NONE; // 管理组件绘制步骤

  private readonly _TOP_BAR_ANCHOR = 'top_bar_month';
  private readonly _GUIDELINE_SUFFIX = 'guideline_';
  private _guidelineIdArray: string[] = [];
  private readonly _PERIOD_SUFFIX = 'period_';
  private _periodIdArray: string[] = [];
  private readonly _SCHEDULE_INDEX_SUFFIX = 'schedule_index_';
  private _scheduleIndexIdArray: string[] = [];
  private readonly _SCHEDULE_INFO_SUFFIX = 'schedule_info_';
  private _scheduleInfoIdArray: string[] = [];
  private readonly _colorPaletteCount = 11; // 调色盘数量

  @Computed get dateList(): Date[] {
    const dateList: Date[] = [];
    const startTime = ScheduleConfigUtil.normalizeDate(this.scheduleWeek[0]);
    const endTime = ScheduleConfigUtil.normalizeDate(this.scheduleWeek[1]);
    const currentTime = startTime;
    while (currentTime.getTime() <= endTime.getTime()) {
      dateList.push(new Date(currentTime));
      currentTime.setDate(currentTime.getDate() + 1);
    }
    return dateList;
  }

  aboutToAppear(): void {
    // 初始化各组件id数组
    this.initComponentId();
  }

  initComponentId() {
    // guideline id初始化
    const guidelineCount = 7;
    NumberUtil.range(guidelineCount * 2).forEach((item: number, index: number) => {
      this._guidelineIdArray.push(`${this._GUIDELINE_SUFFIX}${index}`);
    });
    // 日程阶段 id 初始化
    this.divideTimes.forEach((item: TimeInfo, timePeriodIndex: number) => {
      this._periodIdArray.push(`${this._PERIOD_SUFFIX}${timePeriodIndex}`);
    });
    // 日程下标 id 初始化
    NumberUtil.range(this.scheduleMaxIndex + 1).forEach((item: number, index: number) => {
      this._scheduleIndexIdArray.push(`${this._SCHEDULE_INDEX_SUFFIX}${index}`);
    });
    // 日程信息 id 初始化
    this.scheduleList.forEach((item: ScheduleInfo, index: number) => {
      this._scheduleInfoIdArray.push(`${this._SCHEDULE_INFO_SUFFIX}${index}`);
    });
  }

  build() {
    RelativeContainer() {
      // 顶部日期展示
      this.topDateBarBuilder();

      Scroll() {
        RelativeContainer() {
          // 时间段分割，日程时段排布
          this.scheduleDivideBuilder();
          // 日程信息展示
          this.scheduleFlowBuilder();
        }
        .width(ComponentConst.FULL_PARENT)
        .height(ComponentConst.AUTO_SIZE)
        .guideLine(this.verticalGuidelines)
      }
      .width(ComponentConst.FULL_PARENT)
      .alignRules({
        top: ComponentConst.bindBottom(this._TOP_BAR_ANCHOR),
        bottom: ComponentConst.bindBottom(),
      })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .margin({ top: ComponentConst.PAGE_VERTICAL_PADDING })
      .id('schedule_flow_container')
    }
    .width(ComponentConst.FULL_PARENT)
    .height(ComponentConst.FULL_PARENT)
    .guideLine(this.verticalGuidelines)
    .id('schedule_flow_root')
  }

  @Builder topDateBarBuilder() {
    // 开始月份
    Column() {
      Text(pad(this.scheduleWeek[0].getMonth() + 1))
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('app.color.system_color_h1_black'))
      Text($r('app.string.month'))
        .fontSize($r('app.string.font_size_10'))
        .fontColor($r('app.color.system_color_h1_black'))
        .margin({ top: 2 })
    }
    .verticalCapsule()
    .id(this._TOP_BAR_ANCHOR)
    .margin({
      top: this.verticalPadding,
      left: this.horizontalPadding,
    })
    .onAppear(() => {
      this.computeVerticalGuideline();
    })

    // 具体日期展示
    if (this.drawStep === DrawStep.VERTICAL_GUIDELINE) {
      ForEach(this.dateList, (dateTime: Date, index: number) => {
        Column() {
          Text($r(`app.string.week_${index + 1}`))
            .fontSize($r('sys.float.Body_M'))
            .fontColor(ScheduleConfigUtil.isSameDate(dateTime, this.currentDate) ?
              Color.White :
              $r('app.color.system_color_h1_black')
            )
          Text() {
            if (dateTime.getDate() !== 1) {
              Span(`${pad(dateTime.getMonth() + 1)}`)
              Span('.')
              Span(`${pad(dateTime.getDate())}`)
            } else {
              Span(`${dateTime.getMonth() + 1}`)
              Span($r('app.string.month'))
            }
          }
          .fontSize($r('app.string.font_size_10'))
          .fontColor(ScheduleConfigUtil.isSameDate(dateTime, this.currentDate) ?
            Color.White :
            $r('app.color.system_color_h1_black')
          )
          .margin({ top: 2 })
        }
        .width(ComponentConst.AUTO_SIZE)
        .height(ComponentConst.AUTO_SIZE)
        .borderRadius($r('app.string.padding_xs'))
        .backgroundColor(ScheduleConfigUtil.isSameDate(dateTime, this.currentDate) ?
          $r('sys.color.multi_color_09') :
          Color.White
        )
        .padding({
          top: $r('app.string.padding_xs'),
          bottom: $r('app.string.padding_xs'),
          left: $r('app.string.padding_s'),
          right: $r('app.string.padding_s'),
        })
        .alignRules({
          top: ComponentConst.bindTop(this._TOP_BAR_ANCHOR),
          bottom: ComponentConst.bindBottom(this._TOP_BAR_ANCHOR),
          left: ComponentConst.bindStart(this.verticalGuidelines[(index + 1) * 2].id),
          right: ComponentConst.bindEnd(this.verticalGuidelines[(index + 1) * 2 + 1].id),
        })
      }, (item: Date) => item.toLocaleString())
    }
  }

  computeVerticalGuideline() {
    const topBarInfo = componentUtils.getRectangleById(this._TOP_BAR_ANCHOR);
    const parentInfo = componentUtils.getRectangleById('schedule_flow_root');
    const leftVp = px2vp(topBarInfo.localOffset.x + topBarInfo.size.width);
    const parentWidth = px2vp(parentInfo.size.width);
    const space = 8; // 组件间距（包括首尾）
    const count = 7; // 日期个数
    const targetWidth = (parentWidth - leftVp - (count + 1) * space) / count;
    let newVerticalGuidelines: GuideLineStyle[] = [];
    for (let i = 0; i < count; i++) {
      newVerticalGuidelines.push({
        id: this._guidelineIdArray[i * 2],
        direction: Axis.Vertical,
        position: { start: leftVp + space + i * (space + targetWidth) },
      });
      newVerticalGuidelines.push({
        id: this._guidelineIdArray[i * 2 + 1],
        direction: Axis.Vertical,
        position: { start: leftVp + (i + 1) * (space + targetWidth) },
      });
    }
    // 对齐guideline id与日期下标，以便后续课程排布定位
    // 修改前“周二 - this.verticalGuidelines[2] && this.verticalGuidelines[3](index = 1, index * 2 = 2, index * 2 + 1 = 3)”
    // 修改后“周二 - this.verticalGuidelines[4] && this.verticalGuidelines[5](index = 2, index * 2 = 4, index * 2 + 1 = 5)”
    const emptyGuidelineStyle0: GuideLineStyle = { id: 'empty_guideline_0', direction: Axis.Vertical, position: { start: 0 } };
    const emptyGuidelineStyle1: GuideLineStyle = { id: 'empty_guideline_1', direction: Axis.Vertical, position: { start: 0 } };
    newVerticalGuidelines = [emptyGuidelineStyle0, emptyGuidelineStyle1, ...newVerticalGuidelines];
    this.verticalGuidelines = newVerticalGuidelines;
    this.drawStep = DrawStep.VERTICAL_GUIDELINE;
  }

  @Builder scheduleDivideBuilder() {
    ForEach(this.divideTimes, (timeInfo: TimeInfo, timePeriodIndex: number) => {
      Row() {
        Text(timeInfo.periodName)
          .fontSize($r('app.string.font_size_16'))
          .fontColor($r('app.color.system_color_h1_black'))
      }
      .width(ComponentConst.FULL_PARENT)
      .alignRules({
        top: timePeriodIndex === 0 ?
          undefined :
          ComponentConst.bindBottom(this._scheduleIndexIdArray[this.divideTimes[timePeriodIndex - 1].divideTime]),
      })
      .id(this._periodIdArray[timePeriodIndex])
      .backgroundColor($r('sys.color.background_secondary'))
      .margin({ top: $r('app.string.padding_xs') })
      .padding({
        top: $r('app.string.padding_xm'),
        bottom: $r('app.string.padding_xm'),
        left: $r('app.string.padding_xm'),
      })

      ForEach(this.getDivideIndexRange(timePeriodIndex), (scheduleIndex: number, index: number) => {
        Column() {
          Text(`${scheduleIndex}`)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('app.color.system_color_h1_black'))
        }
        .verticalCapsule()
        .alignRules({
          top: ComponentConst.bindBottom(index === 0 ?
            this._periodIdArray[timePeriodIndex] :
            this._scheduleIndexIdArray[scheduleIndex - 1]
          ),
        })
        .margin({
          top: $r('app.string.margin_m'),
          left: this.horizontalPadding,
        })
        .id(this._scheduleIndexIdArray[scheduleIndex])
      }, (item: ScheduleInfo) => item.scheduleName)
    }, (item: TimeInfo) => item.periodName.toString())
  }

  @Builder scheduleFlowBuilder() {
    if (this.drawStep === DrawStep.VERTICAL_GUIDELINE) {
      ForEach(this.scheduleList, (scheduleInfo: ScheduleInfo, index: number) => {
        Stack() {
          Text(scheduleInfo.scheduleName)
            .width(ComponentConst.FULL_PARENT)
            .height(ComponentConst.FULL_PARENT)
            .fontSize($r('app.string.font_size_10'))
            .fontColor(this.getScheduleInfoColor(index))
            .maxLines(4)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .borderRadius(ComponentConst.CARD_RADIUS_SMALL)
        }
        .borderWidth(1)
        .borderColor(this.getScheduleInfoColor(index, 0.4))
        .borderRadius(ComponentConst.CARD_RADIUS_SMALL)
        .backgroundColor(this.getScheduleInfoColor(index, 0.1))
        .alignRules({
          top: ComponentConst.bindTop(this._scheduleIndexIdArray[scheduleInfo.daySchedule[0]]),
          bottom: ComponentConst.bindBottom(this._scheduleIndexIdArray[scheduleInfo.daySchedule[1]]),
          left: ComponentConst.bindStart(this.verticalGuidelines[scheduleInfo.weekDay * 2].id),
          right: ComponentConst.bindEnd(this.verticalGuidelines[scheduleInfo.weekDay * 2 + 1].id),
        })
        .padding({ left: 2, right: 2 })
        .margin({ bottom: $r('app.string.margin_m') })
        .id(this._scheduleInfoIdArray[index])
        .onClick(() => {
          this.scheduleClick?.(scheduleInfo);
        })
      }, (item: ScheduleInfo) => item.scheduleName)
    }
  }

  getScheduleInfoColor(scheduleInfoIndex: number, opacity: number = 1): string {
    return ColorUtil.getResourceColor(`schedule_info_color_${pad(scheduleInfoIndex % this._colorPaletteCount + 1)}`, opacity);
  }

  getDivideIndexRange(divideTimeIndex: number): number[] {
    const startIndex = divideTimeIndex === 0 ? 1 : this.divideTimes[divideTimeIndex - 1].divideTime + 1;
    const endIndex = this.divideTimes[divideTimeIndex].divideTime + 1;
    return NumberUtil.range([startIndex, endIndex]);
  }
}