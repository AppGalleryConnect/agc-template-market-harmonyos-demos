import dayjs from 'dayjs'
import { CALCULATION_TYPE, LuckyDays } from '../model/Model'
import { BaseTextStyleModifier } from '../model/TextStyleModifier'

@ComponentV2
export struct BaseLunarCard {
  /**
   * 当前宜忌信息
   */
  @Require @Param lunarInfo: LuckyDays = new LuckyDays()
  /**
   * 卡片点击事件
   */
  @Event onLunarInfoCardClick: (lunarInfo: LuckyDays) => void = () => {}

  isWeekDay(item: LuckyDays) {
    return ['星期日', '星期六'].includes(item.weekday)
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row({ space: 12 }) {
        Column({ space: 12 }) {
          Text(dayjs(this.lunarInfo.solarDate).format('YYYY.MM-DD').split('-')[0])
            .attributeModifier(new BaseTextStyleModifier(`${this.isWeekDay(this.lunarInfo) ? '#C4272B' :
              'font_primary'}/Body_S/Regular`))
          Text(dayjs(this.lunarInfo.solarDate).format('YYYY.MM-DD').split('-')[1])
            .attributeModifier(new BaseTextStyleModifier(`${this.isWeekDay(this.lunarInfo) ? '#C4272B' :
              'font_primary'}/30/Regular`))
          Text(this.lunarInfo.weekday)
            .attributeModifier(new BaseTextStyleModifier(`${this.isWeekDay(this.lunarInfo) ? '#C4272B' :
              'font_primary'}/Body_S/Regular`))
        }
        .border({
          width: { right: 1 },
          color: { right: '#ccc' },
        })
        .padding({ right: 16 })

        Column({ space: 5 }) {
          Text(this.lunarInfo.lunarDate)
            .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_S/Regular'))
          Row({ space: 5 }) {
            Text(this.lunarInfo.ganZhiYear)
              .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_S/Regular'))
            Text(this.lunarInfo.ganZhiMonth)
              .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_S/Regular'))
            Text(this.lunarInfo.ganZhiDay)
              .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_S/Regular'))
          }

          Row({ space: 5 }) {
            Text('值神：天刑')
              .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
            Text('十二神：满日')
              .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
          }


          Text('星宿：胃土雉宿星')
            .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
        }
        .alignItems(HorizontalAlign.Start)
      }

      Row() {
        Text(this.lunarInfo.daysFromNow ? this.lunarInfo.daysFromNow.toString() : '今天')
          .attributeModifier(new BaseTextStyleModifier('font_primary/Body_L/Bold'))
        Text(this.lunarInfo.forwardOrBack === CALCULATION_TYPE.FORWARD ? '天前' : '天后')
          .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
          .visibility(this.lunarInfo.daysFromNow ? Visibility.Visible : Visibility.None)
      }
    }
    .padding({
      top: 14,
      bottom: 14,
      left: 12,
      right: 12,
    })
    .onClick(() => {
      this.onLunarInfoCardClick(this.lunarInfo)
    })
    .backgroundColor('#FDF7EE')
    .borderRadius(16)
  }
}