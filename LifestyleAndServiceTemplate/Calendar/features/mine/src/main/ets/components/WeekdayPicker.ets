import { PersistenceV2 } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { ThemeModel, WeekStart } from 'common';

const TAG = '[WeekdayPicker]'

@ComponentV2
export struct WeekdayPicker {
  @Require @Param dayList: string[]
  @Event weekdayConfirm: () => void = () => {
  }
  @Local currentIndex: number = 0;
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Local weekStart: WeekStart = PersistenceV2.connect(WeekStart, () => new WeekStart())!;

  aboutToAppear(): void {
    this.currentIndex = this.weekStart.startWeek
  }

  build() {
    Column() {
      TextPicker({ range: this.dayList, selected: this.weekStart.startWeek })
        .textStyle({
          color: $r('sys.color.font_primary'),
          font: { size: $r('sys.float.Body_L'), weight: FontWeight.Normal },
        })
        .selectedTextStyle({
          color: this.theme.themeState.calendarColor,
          font: { size: $r('sys.float.Title_S'), weight: FontWeight.Medium },
        })
        .onChange((value: string | string[], index: number | number[]) => {
          this.currentIndex = index as number
          UtilLog.info(TAG, 'Picker item changed, value: ' + value + ', index: ' + index)
        })
        .onScrollStop((value: string | string[], index: number | number[]) => {
          UtilLog.info(TAG, 'Picker scroll stopped, value: ' + value + ', index: ' + index)
        })
        .canLoop(false)
        .height(150)
      Button('应用')
        .padding({ top: 10, bottom: 10 })
        .width('100%')
        .fontColor(this.theme.themeState.titleColor)
        .backgroundColor(this.theme.themeState.current)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .margin({ top: 25 })
        .onClick(() => {
          this.weekStart.startWeek = this.currentIndex
          this.weekdayConfirm()
          PersistenceV2.save(WeekStart)
        })
    }
    .height('100%')
    .padding({ left: 16, right: 16 })
  }
}