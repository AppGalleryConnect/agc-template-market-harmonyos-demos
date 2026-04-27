import { CardData, CardStyle } from '../model/model';

@ComponentV2
export struct TopicCard {
  @Param @Require cardData:CardData;
  @Event itemClick:() => void = () => {};
  defaultStyle:CardStyle = {
    titleFontSize:16,
    titleColor: 'rgba(0,0,0,0.9)',
    timeFontSize: 12,
    timeColor: 'rgba(0,0,0,0.6)',
    descriptionFontSize:12,
    descriptionColor:'rgba(0,0,0,0.6)',
    contentFontSize:14,
    contentColor: 'rgba(0,0,0,0.6)',
    borderRadius:16,
    bgColor: '#fff'
  }
  @Param cardStyle: CardStyle = this.defaultStyle;

  build() {
    Column({space:16}) {
      Column({space:4}) {
        Row() {
          Text(this.cardData.description)
            .fontSize(this.cardStyle.descriptionFontSize || this.defaultStyle.descriptionFontSize)
            .fontWeight(FontWeight.Regular)
            .fontColor(this.cardStyle.descriptionColor || this.defaultStyle.descriptionColor)

          Text(this.cardData.time)
            .fontSize(this.cardStyle.timeFontSize || this.defaultStyle.timeFontSize)
            .fontWeight(FontWeight.Regular)
            .fontColor(this.cardStyle.timeColor || this.defaultStyle.timeColor)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')

      }

      Column() {
        Text(this.cardData.title)
          .fontSize(this.cardStyle.titleFontSize || this.defaultStyle.titleFontSize)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.cardStyle.titleColor || this.defaultStyle.titleColor)
          .maxLines(2)
          .textOverflow({
            overflow:TextOverflow.Ellipsis
          })
        Row() {
          Text('点击查看详情 >')
            .fontSize(12)
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(0,0,0,0.6)')
            .lineHeight(18)
        }

      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .borderRadius(this.cardStyle.borderRadius || this.defaultStyle.borderRadius)
    .backgroundColor(this.cardStyle.bgColor || this.defaultStyle.bgColor)
    .padding({
      top: 16,
      bottom: 16,
      left: 12,
      right: 12
    })
    .onClick(() => {
      this.itemClick()
    })
  }
}