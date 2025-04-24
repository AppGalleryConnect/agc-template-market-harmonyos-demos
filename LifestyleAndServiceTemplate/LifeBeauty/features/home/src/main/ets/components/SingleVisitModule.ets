import { CommonUtils, getSingleVisitCardList, ISingleVisitCard, RouterMap, RouterModule } from 'utils'

@ComponentV2
export struct SingleVisit {
  @Require @Param cardInfo: ISingleVisitCard;

  build() {
    Column() {
      Column({ space: 4 }) {
        Text(this.cardInfo.title).fontColor($r('app.color.single_card')).fontWeight(500)
        Text() {
          Span('￥' + CommonUtils.handleCash(this.cardInfo.vipPrice))
          Span(`/${this.cardInfo.availableNum}次`).fontSize(12)
        }
        .fontColor($r('app.color.single_card'))
        .fontWeight(500)
        .textAlign(TextAlign.Start)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({
        top: 10,
        bottom: 6,
        left: 10,
        right: 10,
      })
      .borderRadius({ topLeft: 8, topRight: 8 })


      Text('单次仅￥' + CommonUtils.handleCash(this.cardInfo.vipPrice / this.cardInfo.availableNum))
        .fontSize(10)
        .fontColor($r('app.color.single_card'))
        .fontWeight(500)
        .width('100%')
        .height(20)
        .padding({ left: 10 })
        .backgroundColor(Color.White)
        .opacity(0.5)
        .borderRadius({ bottomLeft: 8, bottomRight: 8 })
    }
    .width('100%')
    .backgroundImage($r('app.media.home_single_card_bg'))
    .backgroundImageSize(ImageSize.Cover)
    .borderRadius(8)
    .onClick(() => {
      RouterModule.push({ url: RouterMap.SINGLE_CARD_DETAIL, param: this.cardInfo });
    })

  }
}

@ComponentV2
export struct SingleVisitList {
  @Local list: ISingleVisitCard[] = [];

  aboutToAppear(): void {
    getSingleVisitCardList().then((resp) => {
      this.list = resp;
    })
  }

  build() {
    Column({ space: 10 }) {
      Text('超值次卡').fontSize(16).fontWeight(500).alignSelf(ItemAlign.Start)
      Grid() {
        ForEach(this.list, (item: ISingleVisitCard) => {
          GridItem() {
            SingleVisit({ cardInfo: item })
          }
        }, (v: ISingleVisitCard) => JSON.stringify(v))
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
    }
    .width('100%')
    .padding(10)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }
}