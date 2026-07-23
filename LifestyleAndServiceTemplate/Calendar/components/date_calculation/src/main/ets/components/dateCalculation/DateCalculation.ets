import dayjs from 'dayjs';
import {
  baseActionSheet,
  DividerTmp,
  BaseTextPicker,
  BaseDatePicker,
  BaseTextStyleModifier,
  BaseLunarCard,
} from 'base_apis';
import { calculateDaysLater } from '../../utils/Utils';
import { CALCULATION_TYPE, LuckyDays } from '../../model/model';

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
   * 当前主题色
   */
  @Param selectColor: ResourceStr = '#c4272b'
  /**
   * 分割线
   */
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
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
  private context: UIContext = this.getUIContext();

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
        baseActionSheet.close(this.context)
      },
      cancel: () => {
        baseActionSheet.close(this.context)
      },
    })
  }

  @Builder
  datePickerBuilder(type: string) {
    BaseDatePicker({
      datePicker: this.datePicker,
      selectColor: this.selectColor,
      confirm: (date: Date) => {
        this.localStartDate = dayjs(date).format('YYYY-MM-DD')
        baseActionSheet.close(this.context, 'datePickerBuilder')
      },
      cancel: () => {
        baseActionSheet.close(this.context, 'datePickerBuilder')
      },
    })
  }

  build() {
    Column() {
      Text('某日期前后几天是什么日子')
        .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))

      List({ space: 16 }) {
        ListItem() {
          Column() {
            Row() {
              Text('起始日')
                .attributeModifier(new BaseTextStyleModifier(`font_primary/Subtitle_M/Medium`))
              Row({ space: 5 }) {
                Text(dayjs(this.localStartDate).format('YYYY年MM月DD日'))
                  .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))
                Image($r('app.media.chevron_right')).width(12).height(24)
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              this.datePicker = new Date(this.startDate)
              baseActionSheet.show(this.context, {
                id: 'datePickerBuilder',
                detents: [300, 301],
                showClose: false,
                customContent: () => {
                  this.datePickerBuilder('start')
                },
              })
            });

            Divider()
              .margin({ top: 16, bottom: 16 })
            Row() {
              Text('天数')
                .attributeModifier(new BaseTextStyleModifier(`font_primary/Subtitle_M/Medium`))
              Row({ space: 5 }) {
                Text(this.dayCount.toString())
                  .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))
                Image($r('app.media.chevron_right')).width(12).height(24)
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              baseActionSheet.show(this.context, {
                id: 'datePickerBuilder',
                detents: [300, 301],
                showClose: false,
                customContent: () => {
                  this.textPickerBuilder()
                },
              })
            });
          }
        }

        ListItem() {
          Row({ space: 18 }) {
            Row({ space: 5 }) {
              Radio({ value: 'Radio1', group: 'radioGroup1' })
                .checked(this.forwardOrBack === CALCULATION_TYPE.FORWARD)
                .onChange((value) => {
                  this.forwardOrBack = CALCULATION_TYPE.FORWARD
                })
              Text('向前')
                .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))
            }

            Row({ space: 5 }) {
              Radio({ value: 'Radio2', group: 'radioGroup1' })
                .checked(this.forwardOrBack === CALCULATION_TYPE.BACKWARD)
                .onChange((value) => {
                  this.forwardOrBack = CALCULATION_TYPE.BACKWARD
                })
              Text('向后')
                .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
        }

        ListItem() {
          Column() {
            Button('查询')
              .backgroundColor(this.buttonColor)
              .fontColor(this.textColor)
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .padding({ top: 12, bottom: 12 })
              .width('100%')
              .margin({ top: 25 })
              .constraintSize({ maxWidth: 450 })
              .onClick(() => {
                this.calculateInfo = calculateDaysLater(this.localStartDate, Number(this.dayCount), this.forwardOrBack)
                this.onSearch(this.calculateInfo)
              })
          }
          .width('100%')
        }

        ListItem() {
          Column() {
            BaseLunarCard({
              lunarInfo: this.calculateInfo,
            })
          }
          .width('100%')
          .margin({ top: 12 })
        }
      }
      .scrollBar(BarState.Off)
      .margin({ bottom: 16, top: 16 })
    }
    .height('100%')
    .margin({ top: 18 })
    .justifyContent(FlexAlign.Start)
    .padding({ left: 16, right: 16 })
  }
}