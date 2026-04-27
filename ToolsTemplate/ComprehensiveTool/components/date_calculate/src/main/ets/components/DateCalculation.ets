import dayjs from 'dayjs';
import { baseActionSheet } from '../apis/ActionSheet';
import { DividerTmp } from '../model/DividerTmp';
import { CALCULATION_TYPE, LuckyDays } from '../model/Index';
import { BaseTextStyleModifier } from '../model/TextStyleModifier';
import { calculateDaysLater } from '../utils/Utils';
import { BaseDatePicker } from './BaseDatePicker';
import { BaseLunarCard } from './BaseLunarCard';
import { BaseTextPicker } from './BaseTextPicker';

@ComponentV2
export struct DateCalculation {
  /**
   * 主题颜色
   */
  @Param buttonColor: ResourceStr = '#c4272b'
  /**
   * 文字颜色
   */
  @Param textColor: ResourceStr = '#ffffff'
  /**
   * 分割线
   */
  @Local egDivider: DividerTmp = new DividerTmp(0.5, 0, 0, $r('sys.color.comp_divider'))
  /**
   * 当前选择日期
   */
  @Local datePicker: Date = new Date()
  /**
   * 传入的初始时间
   */
  @Param startDate: Date = new Date()
  /**
   * 开始时间
   */
  @Local localStartDate: string = ''
  /**
   * 天数
   */
  @Local dayCount: string = '3'
  /**
   * 天数集合
   */
  @Local dayList: string[] = ['1', '2', '3', '4', '5', '6', '7']
  /**
   * 查询日期信息
   */
  @Local calculateInfo: LuckyDays = new LuckyDays()
  /**
   * 前后
   */
  @Local forwardOrBack: CALCULATION_TYPE = CALCULATION_TYPE.FORWARD
  /**
   * 查询事件
   */
  @Event onSearch: (calculateInfo: LuckyDays) => void = () => {
  }

  aboutToAppear(): void {
    this.calculateInfo =
      calculateDaysLater(dayjs(this.startDate).format('YYYY-MM-DD'), Number(this.dayCount), this.forwardOrBack)
    this.localStartDate = dayjs(this.startDate).format('YYYY-MM-DD')
  }

  @Builder
  textPickerBuilder() {
    BaseTextPicker({
      textList: this.dayList,
      selected: this.dayList.findIndex(item => item === this.dayCount),
      confirm: (value: number) => {
        this.dayCount = this.dayList[value]
        baseActionSheet.close()
      },
      cancel: () => {
        baseActionSheet.close()
      },
    }).backgroundColor('#2e3033')
  }

  @Builder
  datePickerBuilder(type: string) {
    BaseDatePicker({
      datePicker: this.datePicker,
      confirm: (date: Date) => {
        this.localStartDate = dayjs(date).format('YYYY-MM-DD')
        baseActionSheet.close('datePickerBuilder')
      },
      cancel: () => {
        baseActionSheet.close('datePickerBuilder')
      },
    })
  }

  build() {
    Column() {
      Text('某日期前后几天是什么日子')
        .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))

      List() {
        ListItem() {
          Row() {
            Text('起始日')
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
            this.datePicker = new Date(this.startDate)
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
            Text('天数')
              .attributeModifier(new BaseTextStyleModifier(`font_primary/Subtitle_M/Medium`))
            Row({ space: 5 }) {
              Text(this.dayCount.toString())
                .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))
              Image($r('app.media.chevron_right_new')).width(12).height(24).fillColor($r('sys.color.icon_fourth'))
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            baseActionSheet.show({
              id: 'datePickerBuilder',
              detents: [300, 301],
              backgroundColor: $r('sys.color.comp_background_primary'),
              showClose: false,
              customContent: () => {
                this.textPickerBuilder()
              },
            }, this.getUIContext())
          });
        }.height(48)

        ListItem() {
          Row({ space: 18 }) {
            Row({ space: 5 }) {
              Radio({ value: 'Radio1', group: 'radioGroup1' })
                .checked(this.forwardOrBack === CALCULATION_TYPE.FORWARD)
                .radioStyle({
                  checkedBackgroundColor: this.buttonColor,
                })
                .onChange((value) => {
                  this.forwardOrBack = CALCULATION_TYPE.FORWARD
                })
              Text('向前')
                .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))
            }

            Row({ space: 5 }) {
              Radio({ value: 'Radio2', group: 'radioGroup1' })
                .checked(this.forwardOrBack === CALCULATION_TYPE.BACKWARD)
                .radioStyle({
                  checkedBackgroundColor: this.buttonColor,
                })
                .onChange((value) => {
                  this.forwardOrBack = CALCULATION_TYPE.BACKWARD
                })
              Text('向后')
                .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))
            }
          }
          .padding({ top: 8 })
          .width('100%')
          .justifyContent(FlexAlign.End)
        }
      }
      .divider(this.egDivider)
      .margin({ top: 8 })

      Button('查询', { type: ButtonType.Normal, stateEffect: true })
        .backgroundColor(this.buttonColor)
        .fontColor(this.textColor)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .padding({ top: 12, bottom: 12 })
        .width('100%')
        .height(40)
        .borderRadius($r('sys.float.corner_radius_level10'))
        .margin({ top: 50 })
        .onClick(() => {
          this.calculateInfo = calculateDaysLater(this.localStartDate, Number(this.dayCount), this.forwardOrBack)
          this.onSearch(this.calculateInfo)
        })
      Column() {
        BaseLunarCard({
          lunarInfo: this.calculateInfo,
        })
      }
      .margin({ top: 12 })
    }
    .height('100%')
    .margin({ top: 18 })
    .justifyContent(FlexAlign.Start)
    .padding({ left: 16, right: 16 })
  }
}