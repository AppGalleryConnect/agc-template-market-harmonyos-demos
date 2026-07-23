import dayjs from 'dayjs';
import { baseActionSheet, DividerTmp, BaseDatePicker, BaseTextStyleModifier } from 'base_apis';
import { calculateDaysBetweenDates, getCurEndAllDate } from '../../utils/Utils';

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
  private context: UIContext = this.getUIContext();

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
      selectColor:this.selectColor,
      confirm: (date: Date) => {
        if (type === 'end') {
          this.localEndDate = dayjs(date).format('YYYY-MM-DD')
        } else {
          this.localStartDate = dayjs(date).format('YYYY-MM-DD')
        }
        baseActionSheet.close(this.context, 'datePickerBuilder')
      },
      cancel: () => {
        baseActionSheet.close(this.context, 'datePickerBuilder')
      },
    })
  }

  build() {
    Column() {
      Text('查询两个日期的间隔天数')
        .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))

      List({ space: 16 }) {
        ListItem() {
          Column() {
            Row() {
              Text('日期2')
                .attributeModifier(new BaseTextStyleModifier(`font_primary/Subtitle_M/Medium`))
              Row({ space: 5 }) {
                Text(dayjs(this.localEndDate).format('YYYY年MM月DD日'))
                  .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))
                Image($r('app.media.chevron_right')).width(12).height(24)
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              this.datePicker = new Date(this.localEndDate)
              baseActionSheet.show(this.context, {
                id: 'datePickerBuilder',
                detents: [300, 301],
                showClose: false,
                customContent: () => {
                  this.datePickerBuilder('end')
                },
              })
            });

            Divider()
              .margin({ top: 16, bottom: 16 })
            Row() {
              Text('日期1')
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
              this.datePicker = new Date(this.localStartDate)
              baseActionSheet.show(this.context, {
                id: 'datePickerBuilder',
                detents: [300, 301],
                showClose: false,
                customContent: () => {
                  this.datePickerBuilder('start')
                },
              })
            });
          }
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
              .margin({ top: 48 })
              .onClick(() => {
                this.calculateDaysBetweenDates()
                this.onSearch(this.betweenDates)
              })
              .constraintSize({ maxWidth: 450 })
          }
          .width('100%')
        }

        ListItem() {
          Column() {
            Column() {
              Text(`间隔${this.betweenDates.toString()}天`)
                .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Medium`))
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            .borderRadius(16)
            .backgroundColor('#FDF7EE')
            .constraintSize({ maxWidth: 450 })
          }
          .width('100%')
        }
      }
      .margin({ bottom: 16, top: 16 })
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .margin({ top: 18 })
    .justifyContent(FlexAlign.Start)
    .padding({ left: 16, right: 16 })
  }
}