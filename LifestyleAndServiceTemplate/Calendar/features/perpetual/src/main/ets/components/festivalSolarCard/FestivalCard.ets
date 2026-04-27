import { BaseTextStyleModifier } from 'base_apis'
import { FestivalInfo } from '../../model/Model'

@ComponentV2
export struct FestivalCard {
  /**
   * 传入节日节气信息
   */
  @Param festivalInfo: FestivalInfo = new FestivalInfo()
  /**
   * 节日节气卡片点击事件
   */
  @Event onFestivalCardClick: (festivalInfo: FestivalInfo) => void = () => {
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Column({ space: 3 }) {
        Text(this.festivalInfo.date.split('-')[2])
          .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_L/Medium'))
        Text(`${this.festivalInfo.date.split('-')[1]}月`)
          .attributeModifier(new BaseTextStyleModifier('font_primary/Body_M/Regular'))
      }
      .margin({ right: 16 })

      Row() {
        Column({ space: 5 }) {
          Text(this.festivalInfo.name)
            .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_S/Medium'))
          Text(this.festivalInfo.date)
            .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
        }
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text(this.festivalInfo.daysUntil === 0 ? '今天' : this.festivalInfo.daysUntil.toString())
            .attributeModifier(new BaseTextStyleModifier('font_primary/Body_L/Bold'))
          Text('天')
            .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_M/Regular'))
            .visibility(this.festivalInfo.daysUntil === 0 ? Visibility.None : Visibility.Visible)
        }
      }
      .padding({
        left: 12,
        right: 12,
        top: 10,
        bottom: 10,
      })
      .flexGrow(1)
      .borderRadius(8)
      .backgroundColor('#FDF7EE')
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.onFestivalCardClick(this.festivalInfo)
      })
    }
  }
}
