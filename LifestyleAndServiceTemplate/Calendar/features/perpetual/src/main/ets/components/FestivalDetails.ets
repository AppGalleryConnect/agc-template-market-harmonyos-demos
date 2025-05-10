import { FestivalList, NavigationTitle, TextStyleModifier } from 'common'

@Builder
export function FestivalDetailsBuilder() {
  FestivalDetails()
}

@ComponentV2
export struct FestivalDetails {
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @Local festivalInfo: FestivalList = new FestivalList()

  getNavigationParams() {
    this.festivalInfo =
      this.pageInfos.getParamByName('FestivalDetails')[0] as FestivalList
  }

  aboutToAppear(): void {
    this.getNavigationParams()
  }

  build() {
    NavDestination() {
      NavigationTitle({
        title: this.festivalInfo.name
      })
      Column() {
        Column({ space: 5 }) {
          Text(this.festivalInfo.name)
            .attributeModifier(new TextStyleModifier('font_primary/Title_M/Bold'))
          Text(this.festivalInfo.date)
            .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 12 })

        Column({ space: 8 }) {
          Text('简介')
            .attributeModifier(new TextStyleModifier('font_primary/Subtitle_L/Bold'))
          Row() {
            Text('节日时间：')
              .attributeModifier(new TextStyleModifier('font_secondary/Body_M/Regular'))
            Text('每年6月5日或6日')
              .attributeModifier(new TextStyleModifier('font_primary/Body_M/Regular'))
          }

          Row() {
            Text('代表寓意：')
              .attributeModifier(new TextStyleModifier('font_secondary/Body_M/Regular'))
            Text('麦芒等有芒作物成熟，农民朋友播种')
              .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
          }

          Row() {
            Text('气候特点：')
              .attributeModifier(new TextStyleModifier('font_secondary/Body_M/Regular'))
            Text('雨量充沛，气温显著升高')
              .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
          }

          Row() {
            Text('节气养生：')
              .attributeModifier(new TextStyleModifier('font_secondary/Body_M/Regular'))
            Text('饮食清淡、调养精神')
              .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
          }

          Row() {
            Text('节气三候：')
              .attributeModifier(new TextStyleModifier('font_secondary/Body_M/Regular'))
            Text('螳螂生；鹏始鸣；反舌无声')
              .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
          }

          Row() {
            Text('芒种是农历二十四节气中的第9个节气，夏季的 第三个节气、表示仲夏时节的正式开始。')
              .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
          }
        }
        .padding(12)
        .backgroundColor($r('sys.color.background_primary'))
        .borderRadius(16)
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .padding({ left: 16, right: 16 })
      .margin({ top: 16 })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}