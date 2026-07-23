import { DividerTmp, BaseTextStyleModifier, getDataFromJSON } from 'base_apis'
import { PublicHolidayInfo } from '../../model/model'


@ComponentV2
export struct PublicHolidays {
  /**
   * 传入的日期
   */
  @Param selectedDate: Date = new Date()
  /**
   * 假期信息
   */
  @Local holidaysList: PublicHolidayInfo[] = []
  /**
   * 分割线
   */
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  /**
   * 公众假日卡片事件
   */
  @Event onHolidayCardClick: (festivalInfo: PublicHolidayInfo) => void = () => {
  }

  aboutToAppear(): void {
    this.holidaysList =
      getDataFromJSON<PublicHolidayInfo>(this.getUIContext().getHostContext()!, 'Public_Holidays.json');
  }

  @Builder
  publicHolidayCard(holiday: PublicHolidayInfo) {
    Row({ space: 20 }) {
      Column({ space: 5 }) {
        Text(holiday.day)
          .attributeModifier(new BaseTextStyleModifier('#966426/Caption_M/Regular'))
        Text(holiday.weekDay)
          .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
      }

      Column({ space: 5 }) {
        Text(holiday.name)
          .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_M/Medium'))
        Row({ space: 8 }) {
          Text() {
            Span('假期：')
            Span(holiday.holiday)
          }
          .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))

          Text(`共${holiday.totalRest}天`)
            .attributeModifier(new BaseTextStyleModifier('#966426/Body_S/Regular'))
        }


        Text() {
          Span('调休：')
          Span(holiday.adjustWorkDays)
        }
        .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
      }
      .alignItems(HorizontalAlign.Start)
    }
    .onClick(() => {
      this.onHolidayCardClick(holiday)
    })
  }

  build() {
    Column() {
      Row() {
        Text(`2026年`)
          .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_M/Regular'))
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .margin({ bottom: 20, top: 12 })

      List({ space: 16 }) {
        ForEach(this.holidaysList, (item: PublicHolidayInfo) => {
          ListItem() {
            this.publicHolidayCard(item)
          }
        }, (item: PublicHolidayInfo) => item.name.toString())
      }
      .divider(this.egDivider)
      .scrollBar(BarState.Off)
      .height('100%')
      .layoutWeight(1)
    }
    .padding({ left: 16, right: 16 })
  }
}
