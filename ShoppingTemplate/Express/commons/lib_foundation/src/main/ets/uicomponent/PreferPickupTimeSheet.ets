import { ITime } from '../common/CommonEnum';
import { TIME_LIST } from '../common/Constant';

export interface PreferPickupTimeParam {
  currentDay: string,
  currentTime: string,
  dayList: ITime[],
  confirm: (day: number, time: string) => void,
  cancel: () => void,
}

@Builder
export function preferPickupTimeSheetBuilder(param: PreferPickupTimeParam) {
  PreferPickupTimeSheet({
    currentDay: param.currentDay,
    currentTime: param.currentTime,
    dayList: param.dayList,
    confirm: param.confirm,
    cancel: param.cancel,
  })
}

@ComponentV2
struct PreferPickupTimeSheet {
  @Param currentDay: string = '';
  @Param currentTime: string = '';
  @Param dayList: ITime[] = [];
  @Event confirm: (day: number, time: string) => void;
  @Event cancel: () => void;
  @Local timePickerList: string[] = TIME_LIST;
  @Local selectedDayIndex: number = 0;
  @Local selectedTimeIndex: number = 0;

  aboutToAppear(): void {
    const dayIndex = this.dayList.findIndex((item) => item.text === this.currentDay);
    this.selectedDayIndex = dayIndex > -1 ? dayIndex : 0;
    this.timePickerList = this.dayList[this.selectedDayIndex].timeList;
    const timeIndex = this.timePickerList.findIndex((item) => item === this.currentTime);
    this.selectedTimeIndex = timeIndex > -1 ? timeIndex : 0;
  }

  build() {
    Column() {
      Row() {
        Column() {
          ForEach(this.dayList, (day: ITime, index: number) => {
            Row() {
              Text(day.text)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.selectedDayIndex === index ?
                  $r('sys.color.font_emphasize') : $r('sys.color.font_primary')
                )
            }
            .width('100%')
            .height(60)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.selectedDayIndex === index ? Color.White : Color.Transparent)
            .onClick(() => {
              this.selectedDayIndex = index;
              this.timePickerList = this.dayList[index].timeList;
            })
          }, (item: ITime[]) => JSON.stringify(item))
        }
        .width(100)

        TextPicker({ range: this.timePickerList, selected: $$this.selectedTimeIndex })
          .width(200)
          .disappearTextStyle({ color: Color.Black, font: { size: 14, weight: FontWeight.Regular } })
          .textStyle({ color: Color.Black, font: { size: 16, weight: FontWeight.Regular } })
          .selectedTextStyle({
            color: $r('sys.color.font_emphasize'),
            font: { size: 20, weight: FontWeight.Medium }
          })
      }
      .width('100%')

      Row({space: 12}) {
        Button('取消')
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .flexGrow(1)
          .onClick(() => {
            this.cancel();
          })

        Button('确认')
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .flexGrow(1)
          .onClick(() => {
            const dayIndex = this.selectedDayIndex;
            const time = this.timePickerList[this.selectedTimeIndex]
            this.confirm(dayIndex, time);
          })
      }
      .width('100%')
      .margin({ top: 28 })
    }
    .padding({ left: 16, right: 16 })
  }
}