import { DataPreferencesUtils } from '@ohos_agcit/office_attendance_common_lib';
import { DateElement } from '@ohos_agcit/office_attendance_component_lib/src/main/ets/types/DateElement';

@ComponentV2
export struct ScheduleTitle {
  @Param selectedMonth: DateElement = new DateElement(0, 0, 0);
  @Param onChange: (selected: DateElement) => void = (selected: DateElement) => {
  }
  @Param onLunarChange: () => void = () => {
  }

  private goBeforeMonth() {
    this.selectedMonth.year =
      this.selectedMonth.month - 1 >= 0 ? this.selectedMonth.year : this.selectedMonth.year - 1;
    this.selectedMonth.month = this.selectedMonth.month - 1 >= 0 ? this.selectedMonth.month - 1 : 11;
    this.onChange(this.selectedMonth);
  }

  private goAfterMonth() {
    this.selectedMonth.year =
      this.selectedMonth.month + 1 < 12 ? this.selectedMonth.year : this.selectedMonth.year + 1;
    this.selectedMonth.month = this.selectedMonth.month + 1 < 12 ? this.selectedMonth.month + 1 : 0;
    this.onChange(this.selectedMonth);
  }

  isSettingLunar() {
    return DataPreferencesUtils.LUNAR_SETTING_ON ===
    DataPreferencesUtils.getSync(DataPreferencesUtils.LUNAR_SETTING, DataPreferencesUtils.LUNAR_SETTING_ON)
  }

  @Builder
  settingBuilder() {
    Column() {
      Row() {
        Row() {
          Text($r('app.string.schedule_lc_desc'))
        }.alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .width('60%')

        Row() {
          if (this.isSettingLunar()) {
            Image($r('app.media.ic_check_mask')).width(24).height(16)
          }
        }.alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.End)
        .layoutWeight(1)
      }.alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        if (this.isSettingLunar()) {
          DataPreferencesUtils.putSync(DataPreferencesUtils.LUNAR_SETTING, DataPreferencesUtils.LUNAR_SETTING_OFF)
        } else {
          DataPreferencesUtils.putSync(DataPreferencesUtils.LUNAR_SETTING, DataPreferencesUtils.LUNAR_SETTING_ON)
        }
        this.onLunarChange();
      })
    }.height(45)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width(240)
    .margin({ top: 10, bottom: 10 })
  }

  build() {
    Row() {
      Row() {
        Row() {
          Image($r('app.media.ic_public_small_left'))
            .id('pre_month')
            .height(20)
            .width(12)
        }
        .margin({ left: 5 })
        .height('100%')
        .aspectRatio(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.goBeforeMonth();
        })
        Column().width('6%')
        Text(`${this.selectedMonth.year}-${this.selectedMonth.month + 1 >= 10 ? '' : '0'}${this.selectedMonth.month +
          1}`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .opacity(0.9)
        Column().width('6%')
        Row() {
          Image($r('app.media.ic_public_small_right'))
            .id('next_month')
            .height(20)
            .width(12)
        }
        .margin({ left: 5 })
        .height('100%')
        .aspectRatio(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.goAfterMonth();
        })
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
      }.width('50%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)

      Row() {
        Image($r('app.media.ic_ellipsis'))
          .width(20)
          .height(12)
          .bindMenu(this.settingBuilder)
      }
      .width('50%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.End)
    }.width('100%')
    .height(24)
  }
}