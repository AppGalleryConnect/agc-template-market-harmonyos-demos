import dayjs from 'dayjs';
import { baseActionSheet } from '../apis/ActionSheet';
import { DividerTmp } from '../model/DividerTmp';
import { LunarInfo } from '../model/Index';
import { BaseTextStyleModifier } from '../model/TextStyleModifier';
import { gregorianToLunar } from '../utils/Utils';
import { BaseDatePicker } from './BaseDatePicker';

@ComponentV2
export struct YinYangConversion {
  /**
   * 主题颜色
   */
  @Param themeColor: ResourceStr = '#c4272b'
  /**
   * 文字颜色
   */
  @Param textColor: ResourceStr = '#ffffff'
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
   * 农历
   */
  @Local lunarDateInfo: LunarInfo = new LunarInfo()
  /**
   * 查询事件
   */
  @Event onSearch: (lunarDateInfo: LunarInfo) => void = () => {
  }

  aboutToAppear(): void {
    this.localStartDate = dayjs(this.startDate).format('YYYY-MM-DD')
    this.getLunarDateInfo()
  }

  getLunarDateInfo() {
    this.lunarDateInfo = gregorianToLunar(new Date(this.localStartDate))
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
      Text('公历转阴历')
        .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))
        .margin({ bottom: 8 })

      List({ space: 20 }) {
        ListItem() {
          Row() {
            Text('选择日期')
              .attributeModifier(new BaseTextStyleModifier(`font_primary/Subtitle_M/Medium`))
            Row({ space: 5 }) {
              Text(dayjs(this.localStartDate).format('YYYY年MM月DD日'))
                .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))
              Image($r('app.media.chevron_right_new')).width(7).height(17)
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            this.datePicker = new Date(this.startDate)
            baseActionSheet.show({
              id: 'datePickerBuilder',
              backgroundColor: $r('sys.color.comp_background_primary'),
              detents: [300, 301],
              showClose: false,
              customContent: () => {
                this.datePickerBuilder('start')
              },
            })
          });
        }

        ListItem() {
          Row({ space: 18 }) {
            Row({ space: 5 }) {
              Radio({ value: 'Radio3', group: 'radioGroup2' })
                .checked(true)
                .radioStyle({
                  checkedBackgroundColor: this.themeColor,
                })

              Text('公历转阴历')
                .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
        }
      }
      .divider(this.egDivider)
      .margin({ bottom: 16, top: 16 })

      Button('查询')
        .backgroundColor(this.themeColor)
        .fontColor(this.textColor)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .padding({ top: 12, bottom: 12 })
        .width('100%')
        .margin({ top: 25 })
        .onClick(() => {
          this.onSearch(this.lunarDateInfo)
          this.getLunarDateInfo()
        })
      Column() {
        Column({ space: 3 }) {
          Text() {
            Span('农历：')
            Span(`${this.lunarDateInfo.year}年${this.lunarDateInfo.month}月${this.lunarDateInfo.day}`)
          }
          .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Medium`))

          Text(this.lunarDateInfo.weekday)
            .attributeModifier(new BaseTextStyleModifier(`font_secondary/Body_S/Regular`))
        }
        .padding(12)
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .borderRadius(16)
        .backgroundColor('#FDF7EE')
      }
      .margin({ top: 12 })
    }
    .height('100%')
    .margin({ top: 18 })
    .justifyContent(FlexAlign.Start)
    .padding({ left: 16, right: 16 })
  }
}