import { CardData } from '../model/model';

@ComponentV2
export struct ArticleCardDetail {
  @Param @Require jobItem: CardData;

  build() {
    Column() {
      Column() {
        Text(this.jobItem.title)
          .fontSize(16)
          .fontWeight(600)
          .lineHeight(21)
        Text(this.jobItem.description)
          .fontSize(14)
          .fontColor('rgba(0,0,0,0.6)')
          .margin({ top: 2 })
          .lineHeight(20)
        Row()
          .height(0.8)
          .backgroundColor('#E5E7E8')
          .width('100%')
          .margin({ top: 10 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({
        bottom: 24
      })

      Column() {
        Text('工作职责')
          .fontSize(18)
          .margin({ bottom: 8 })
          .fontWeight(700)
        Scroll() {
          Text(this.jobItem.content)
            .fontSize(14)
        }
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)


      Column() {
        Text('职位要求')
          .fontSize(18)
          .fontWeight(700)
          .margin({ bottom: 8 })
        Scroll() {
          Text(this.jobItem.content)
            .fontSize(14)
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ top: '10%' })

      Text('发布于 ' + this.jobItem.time)
        .width('100%')
        .fontSize(12)
        .fontColor('#616263')
        .margin({ top: '10%' })
    }
    .width('100%')
  }
}