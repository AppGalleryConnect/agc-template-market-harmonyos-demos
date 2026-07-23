import { getMedia, getString } from '@agctemplate/resources'
import { DramaCoverVM } from '../viewmodels/DramaCoverVM'
import { RankList } from './RankList'

@ComponentV2
export struct SearchResultPanel {

  @Param @Require resultList: Array<DramaCoverVM>
  @Event loadNextPage: Function
  @Event onDramaClick: Function

  build() {
    Row() {
      Column() {
        Row() {
          Text(getString('app.string.drama_search_result_title'))
            .fontWeight(FontWeight.Bold)
            .fontSize(18)
            .margin({
              top: 12, bottom: 12
            })
        }
        .width('100%')

        if (this.resultList.length > 0) {
          Row() {
            Column({ space: 16 }) {
              RankList({
                dramaList: this.resultList,
                scroller: undefined,
                loadNextPage: this.loadNextPage,
                isVertical: true
              })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
        }else {
          Column(){
            this.nullBuilder()
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
  }

  @Builder
  nullBuilder() {
    Column() {
      Image(getMedia('app.media.search_no_result'))
        .width(120)
        .aspectRatio(1)
        .margin({ top: 20 })
      Text(getString('app.string.search_null'))
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_tertiary'))
        .margin({ top: 4, bottom: 10 })
    }
    .padding(12)
    .borderRadius(16)
    .width('100%')
  }
}