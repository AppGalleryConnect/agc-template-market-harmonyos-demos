import { DividerTmp, BaseTextStyleModifier } from 'base_apis';
import dayjs from 'dayjs';
import { COL_SPAN, GRID_ROW_OPTIONS_Y_8 } from '../../constants/Constants';
import { HolidayInfo } from '../../model/model';
import { getPublicFestival } from '../../utils/Utils';

@ComponentV2
export struct PublicFestival {
  /**
   * 传入的日期
   */
  @Param selectedDate: Date = new Date()
  /**
   * 分割线
   */
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  /**
   * 公众节日数据
   */
  @Local publicFestivalInfo: HolidayInfo[] = []
  /**
   * 公众节日卡片事件
   */
  @Event onFestivalCardClick: (festivalInfo: HolidayInfo) => void = () => {
  }

  aboutToAppear(): void {
    this.publicFestivalInfo = getPublicFestival(this.selectedDate)
  }

  getYearInfo() {
    let year = dayjs(this.selectedDate).format('YYYY-MM-DD').split('-')[0]
    return year
  }

  @Builder
  publicFestivalCard(holidayInfo: HolidayInfo) {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row({ space: 20 }) {
        Column({ space: 3 }) {
          Text(holidayInfo.day)
            .attributeModifier(new BaseTextStyleModifier('#966426/Subtitle_M/Medium'))
          Text(holidayInfo.month)
            .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
        }
        .width(30)

        Column({ space: 3 }) {
          Text(holidayInfo.holidayName.toString())
            .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_M/Medium'))
          Text(holidayInfo.solarDate)
            .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
        }
        .alignItems(HorizontalAlign.Start)
      }

      Row() {
        Text(`${holidayInfo.daysUntil.toString()}天`)
          .attributeModifier(new BaseTextStyleModifier('font_primary/Body_M/Regular'))
      }
    }
    .onClick(() => {
      this.onFestivalCardClick(holidayInfo)
    })
    .border({ width: { bottom: 1 }, color: '#ffe9f0f0' })
    .padding({ top: 8, bottom: 8 })
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Text(`${this.getYearInfo()}年`)
            .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_M/Regular'))
        }
        .justifyContent(FlexAlign.Start)
        .width('100%')
        .margin({ bottom: 20, top: 12 })

        GridRow(GRID_ROW_OPTIONS_Y_8) {
          ForEach(this.publicFestivalInfo, (item: HolidayInfo) => {
            GridCol({
              span: COL_SPAN,
            }) {
              this.publicFestivalCard(item)
            }

          }, (item: HolidayInfo) => item.holidayName.toString())
        }
      }
      .justifyContent(FlexAlign.Start)
      .padding({ left: 16, right: 16 })
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
    .padding({ bottom: 16 })
    .edgeEffect(EdgeEffect.Spring)
  }
}
