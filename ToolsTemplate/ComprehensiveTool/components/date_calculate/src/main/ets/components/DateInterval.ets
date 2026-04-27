import dayjs from 'dayjs';
import { baseActionSheet } from '../apis/ActionSheet';
import { DividerTmp } from '../model/DividerTmp';
import { BaseTextStyleModifier } from '../model/TextStyleModifier';
import { calculateDaysBetweenDates, getCurEndAllDate } from '../utils/Utils';
import { BaseDatePicker } from './BaseDatePicker';

@ComponentV2
export struct DateInterval {
  /**
   * 按钮颜色
   */
  @Param buttonColor: ResourceStr = '#c4272b'
  /**
   * 文本颜色
   */
  @Param textColor: ResourceStr = '#ffffff'
  /**
   * 当前选择日期
   */
  @Local datePicker: Date = new Date()
  /**
   * 传入的初始时间
   */
  @Param startDate: Date = new Date()
  /**
   * 分割线
   */
  @Local egDivider: DividerTmp = new DividerTmp(0.5, 0, 0, $r('sys.color.comp_divider'))
  /**
   * 开始时间
   */
  @Local localEndDate: string = ''
  /**
   * 结束时间
   */
  @Local localStartDate: string = ''
  /**
   * 计算值
   */
  @Local betweenDates: number = 0
  /**
   * 查询事件
   */
  @Event onSearch: (betweenDates: number) => void = () => {
  }

  aboutToAppear(): void {
    this.localStartDate = dayjs(this.startDate).format('YYYY-MM-DD')
    this.localEndDate = getCurEndAllDate(this.startDate)
    this.calculateDaysBetweenDates()
  }

  calculateDaysBetweenDates() {
    this.betweenDates = calculateDaysBetweenDates(this.localStartDate, this.localEndDate)
  }

  @Builder
  datePickerBuilder(type: string) {
    BaseDatePicker({
      datePicker: this.datePicker,
      confirm: (date: Date) => {
        if (type === 'end') {
          this.localEndDate = dayjs(date).format('YYYY-MM-DD')
        } else {
          this.localStartDate = dayjs(date).format('YYYY-MM-DD')
        }
        baseActionSheet.close('datePickerBuilder')
      },
      cancel: () => {
        baseActionSheet.close('datePickerBuilder')
      },
    })
  }

  build() {
    Column() {
      Text('查询两个日期的间隔天数')
        .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))

      List() {
        ListItem() {
          Row() {
            Text('日期1')
              .attributeModifier(new BaseTextStyleModifier(`font_primary/Subtitle_M/Medium`))
            Row({ space: 5 }) {
              Text(dayjs(this.localStartDate).format('YYYY年MM月DD日'))
                .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))
              Image($r('app.media.chevron_right_new')).width(12).height(24).fillColor($r('sys.color.icon_fourth'))
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            this.datePicker = new Date(this.localStartDate)
            baseActionSheet.show({
              id: 'datePickerBuilder',
              detents: [300, 301],
              backgroundColor: $r('sys.color.comp_background_primary'),
              showClose: false,
              customContent: () => {
                this.datePickerBuilder('start')
              },
            }, this.getUIContext())
          });
        }
        .height(48)

        ListItem() {
          Row() {
            Text('日期2')
              .attributeModifier(new BaseTextStyleModifier(`font_primary/Subtitle_M/Medium`))
            Row({ space: 5 }) {
              Text(dayjs(this.localEndDate).format('YYYY年MM月DD日'))
                .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))
              Image($r('app.media.chevron_right_new')).width(12).height(24).fillColor($r('sys.color.icon_fourth'))
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            this.datePicker = new Date(this.localEndDate)
            baseActionSheet.show({
              id: 'datePickerBuilder',
              detents: [300, 301],
              backgroundColor: $r('sys.color.comp_background_primary'),
              showClose: false,
              customContent: () => {
                this.datePickerBuilder('end')
              },
            }, this.getUIContext())
          })
        }
        .height(48)

        ListItem()
      }
      .margin({ bottom: 16, top: 8 })
      .divider(this.egDivider)
      .scrollBar(BarState.Off)

      Button('查询', { type: ButtonType.Normal, stateEffect: true })
        .backgroundColor(this.buttonColor)
        .fontColor(this.textColor)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .padding({ top: 12, bottom: 12 })
        .width('100%')
        .height(40)
        .borderRadius($r('sys.float.corner_radius_level10'))
        .margin({ top: 48 })
        .onClick(() => {
          this.calculateDaysBetweenDates()
          this.onSearch(this.betweenDates)
        })
      Column() {
        Text(`间隔${this.betweenDates.toString()}天`)
          .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Medium`))
      }
      .width('100%')
      .margin({ top: 24 })
      .borderRadius(8)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('sys.color.background_tertiary'))
    }
    .height('100%')
    .margin({ top: 18 })
    .justifyContent(FlexAlign.Start)
    .padding({ left: 16, right: 16 })
  }
}