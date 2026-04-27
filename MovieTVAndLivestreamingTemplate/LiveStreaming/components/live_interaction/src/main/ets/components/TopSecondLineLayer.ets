import { LiveItem } from '../models/LiveItem';

@ComponentV2
export struct TopSecondLineLayer {
  @Param @Require rankId: number = 1;
  @Param rankList: LiveItem[] = []
  @Local isShowRankList: boolean = false
  @Event openMoreLive: () => void

  @Builder
  rankListSheet() {
    Column() {
      Column({ space: 16 }) {
        Row() {
          Text('热门主播排行榜')
            .width(232)
            .height(27)
            .fontSize(20)
            .fontWeight(700)
            .margin({ left: 8, right: 8 })
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.xmark'))
              .fontSize(24)
              .fontColor([$r('sys.color.icon_primary')])
          }
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .size({ width: 40, height: 40 })
          .onClick(() => {
            this.isShowRankList = !this.isShowRankList
          })
        }
        .width(328)
        .height(40)
        .margin({ top: 16 })
        .justifyContent(FlexAlign.SpaceBetween)

        List({ space: 12 }) {
          ForEach(
            this.rankList,
            (item: LiveItem) => {
              ListItem() {
                Row({ space: 12 }) {
                  Text(item.rankId + '')
                    .width(20)
                    .textAlign(TextAlign.Center)
                    .fontSize(16)
                    .fontColor(item.rankId === 1 ? '#ffe73a3a' : (item.rankId === 2 ? '#ffd7591d' : (
                      item.rankId === 3 ? '#ffe3af46' : '#aaa'
                    )))
                  Image(item.avatar)
                    .width(50)
                    .height(50)
                    .borderRadius(25)
                  Column({ space: 8 }) {
                    Text(item.nickName)
                      .fontSize(16)
                      .fontWeight(800)
                    Row() {
                      Text(item.category)
                        .fontSize(12)
                        .fontColor('#888')
                        .fontWeight(400)
                      Text('|')
                        .fontSize(12)
                        .fontColor('#888')
                        .fontWeight(400)
                        .margin({ left: 3 })
                      Text(item.watching >= 10000 ? `${item.watching / 10000}万人在看` : `${item.watching}人在看`)
                        .fontSize(12)
                        .fontColor('#888')
                        .fontWeight(400)
                        .margin({ left: 3 })
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  Text(item.hot >= 10000 ? `${item.hot / 10000}万` : `${item.hot}`)
                    .width(40)
                    .textAlign(TextAlign.Center)
                    .fontSize(14)
                    .fontColor('#666')
                    .fontWeight(600)
                }
                .width(328)
                .height(50)
              }
            },
            (item: LiveItem) => item.rankId.toString()
          )
        }
        .height(300)
        .scrollBar(BarState.Off)
      }
      .width(328)
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  build() {
    Stack() {
      Row() {
        Row() {
          Image($r('app.media.rank'))
            .width(20)
            .height(20)
            .margin({
              top: 6,
              bottom: 6,
              right: 4,
              left: 6
            })
          Text('热门榜NO.' + this.rankId)
            .fontColor(Color.White)
            .fontWeight(600)
            .fontSize(12)
        }
        .width(102)
        .height(32)
        .margin({ left: 16 })
        .backgroundColor($r('sys.color.mask_tertiary'))
        .borderRadius(8)
        .bindSheet($$this.isShowRankList, this.rankListSheet(), {
          height: 400,
          showClose: false,
          preferType: SheetType.BOTTOM
        })
        .onClick(() => {
          this.isShowRankList = !this.isShowRankList
        })

        Blank()

        Row() {
          Image($r('app.media.more_live'))
            .width(16)
            .height(16)
            .margin({ left: 6, right: 6 })
          Text('更多直播')
            .fontColor(Color.White)
            .fontSize(12)
            .fontWeight(600)
        }
        .width(86)
        .height(32)
        .borderRadius(8)
        .margin({ right: 16 })
        .backgroundColor($r('sys.color.mask_tertiary'))
        .onClick(() => {
          this.openMoreLive()
        })
      }
      .width('100%')
      .height(32)
    }
    .position({ top: 56 })
  }
}