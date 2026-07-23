import { getMedia, getString } from '@agctemplate/resources'
import { DramaCoverVM } from '../viewmodels/DramaCoverVM'
import { RankList } from './RankList'

@ComponentV2
export struct HotSearchPanel {

  @Param @Require rankList: Array<DramaCoverVM>
  @Event onDramaClick: Function

  build() {
    Row() {
      Column() {
        Row() {
          Column() {
            Image(getMedia('app.media.hot'))
              .width(24)
              .height(24)
          }

          Column() {
            Text(getString('app.string.billboard_category_hot'))
              .fontWeight(FontWeight.Bold)
              .fontSize(18)
              .margin({
                left: 4
              })
          }
        }
        .margin({
          top: 12, bottom: 12
        })

        Row() {
          Column({ space: 16 }) {
            RankList({dramaList: this.rankList, scroller: undefined, isVertical: true})
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .margin({
      left: 16, right: 16
    })
    .alignItems(VerticalAlign.Top)
  }
}