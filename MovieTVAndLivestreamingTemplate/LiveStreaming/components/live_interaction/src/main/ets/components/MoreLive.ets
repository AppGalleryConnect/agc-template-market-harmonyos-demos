@ComponentV2
export struct LiveCard {
  @Param @Require liveData: MoreLiveCard

  build() {
    Column() {
      Stack() {
        Image($r(this.liveData.cover))
          .width(120)
          .height(68)
          .borderRadius({ topLeft: 8, topRight: 8 })

        Row() {
          Image($r('app.media.watcher'))
            .width(10)
            .margin({
              left: 3,
              right: 2,
              bottom: 2,
              top: 3
            })
            .fillColor('#fff')
          if (this.liveData.watching >= 10000) {
            Text(`${(this.liveData.watching / 10000).toFixed(1)}w`)
              .fontSize(8)
              .fontWeight(400)
              .fontColor('#fff')
              .margin({ top: 4, bottom: 4 })
          } else {
            Text(this.liveData.watching.toString())
              .fontSize(8)
              .fontWeight(400)
              .fontColor('#fff')
              .margin({ top: 4, bottom: 4 })
          }

          Row() {
            Text(this.liveData.category)
              .fontSize(8)
              .fontWeight(400)
              .fontColor('#fff')
              .textAlign(TextAlign.End)
              .margin({ top: 4, bottom: 3, right: 3 })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.End)

        }
        .width(120)
        .height(15)
        .backgroundColor($r('sys.color.mask_fourth'))
        .position({ top: 56 })
      }

      Row() {
        Row() {
          Text(this.liveData.title)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize(10)
            .fontWeight(400)
            .textAlign(TextAlign.Start)
            .fontColor('#e6000000')
        }
        .width(76)
        .height(12)
        .margin({ top: 3, right: 3, bottom: 2 })

        Row() {
          Text(this.liveData.streamer)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontWeight(500)
            .fontSize(8)
            .fontColor($r('sys.color.mask_secondary'))
        }
        .justifyContent(FlexAlign.End)
        .layoutWeight(1)
        .height(14)

      }
      .width(120)
      .height(29)
      .backgroundColor('#fff')
      .borderRadius({ bottomLeft: 8, bottomRight: 8 })
    }
    .width(120)
    .height(97)
  }
}


@ComponentV2
export struct LiveList {
  @Local cardsData:MoreLiveCard[] = [];
  @Event onGetMoreLive:Function = ()=>{}
  aboutToAppear(): void {
    this.cardsData = this.onGetMoreLive()
  }
  @Event setHide: () => void
  @Event onLiveClick:Function = (card:LiveCard)=>{}
  build() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .margin({ left: 30 })
          .onClick(() => {
            this.setHide()
          })
        Text('更多直播')
          .width(256)
          .height(27)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')
          .textAlign(TextAlign.Start)
          .margin({ left: 5 })
      }
      .height(56)
      .width('100%')

      Grid() {
        ForEach(this.cardsData, (card: MoreLiveCard) => {
          GridItem() {
            LiveCard({ liveData: card })
          }
          .onClick(() => {
            this.setHide()
            this.onLiveClick(card)
          })
        },(item: MoreLiveCard, index: number) => { return index + '__' + JSON.stringify(item); })
      }
      .width('80%')
      .height('100%')
      .columnsTemplate('repeat(auto-stretch, 120)')
      .columnsGap(8)
      .rowsGap(8)
      .columnsGap(8)
      .margin({ left: 8, right: 8 })
    }
  }
}

export class MoreLiveCard {
  id: number = 0
  cover: string = ''
  title: string = ''
  streamer: string = ''
  category: string = ''
  watching: number = 0
}

