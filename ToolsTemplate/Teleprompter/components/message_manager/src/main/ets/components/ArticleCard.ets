import { LengthMetrics } from '@kit.ArkUI';
import { CardData, CardStyle } from '../model/model';

@ComponentV2
export struct ArticleCard {
  @Param @Require cardData:CardData;
  @Event itemClick:() => void = () => {};
  defaultStyle:CardStyle = {
    titleFontSize:16,
    titleColor: 'rgba(0,0,0,0.9)',
    timeFontSize: 12,
    timeColor: 'rgba(0,0,0,0.6)',
    descriptionFontSize:12,
    descriptionColor:'rgba(0,0,0,0.6)',
    contentFontSize:12,
    contentColor: 'rgba(0,0,0,0.6)',
    borderRadius:16,
    bgColor: '#fff',
    maxLines: 2
  }
  @Param cardStyle: CardStyle = this.defaultStyle;

  build() {
    Column({space:16}) {
      Column({space:4}) {
        Row() {
          Text(this.cardData.title)
            .fontSize(this.cardStyle.titleFontSize || this.defaultStyle.titleFontSize)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.cardStyle.titleColor || this.defaultStyle.titleColor)
          Text(this.cardData.salary || this.cardData.time)
            .fontSize(this.cardStyle.timeFontSize || this.defaultStyle.timeFontSize)
            .fontWeight(FontWeight.Regular)
            .fontColor(this.cardStyle.timeColor || this.defaultStyle.timeColor)

        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        Text(this.cardData.description)
          .fontSize(this.cardStyle.descriptionFontSize || this.defaultStyle.descriptionFontSize)
          .fontWeight(FontWeight.Regular)
          .fontColor(this.cardStyle.descriptionColor || this.defaultStyle.descriptionColor)
          .width('100%')

        Flex({wrap: FlexWrap.Wrap, space: {main:LengthMetrics.vp(8)}}) {
          ForEach(this.cardData.mark, (item:string) => {
            Text(item)
              .borderRadius(4)
              .backgroundColor('rgba(0,0,0,0.05)')
              .fontSize(10)
              .fontColor('rgba(0,0,0,0.9)')
              .padding({
                left:4,
                right:2
              })
          }, (item:string) => item)
        }
        .width('100%')
      }

      Column() {
        Text(this.cardData.content)
          .fontSize(this.cardStyle.contentFontSize || this.defaultStyle.contentFontSize)
          .fontWeight(FontWeight.Regular)
          .fontColor(this.cardStyle.contentColor || this.defaultStyle.contentColor)
          .lineHeight(18)
          .maxLines(this.cardStyle.maxLines || this.defaultStyle.maxLines)
          .textOverflow({
            overflow:TextOverflow.Ellipsis
          })
      }
      .width('100%')
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