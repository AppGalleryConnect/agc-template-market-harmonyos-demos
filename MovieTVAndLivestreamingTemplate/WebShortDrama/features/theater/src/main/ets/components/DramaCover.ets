import { getColor, getMedia, getString } from '@agctemplate/resources'
import { FontModel, fp2pxUtil } from '@agctemplate/widgets'
import { DramaCoverVM } from '../viewmodels/DramaCoverVM'
import { AppStorageV2 } from '@kit.ArkUI'

export function getCoverEpisodeShowText(isEnd: boolean, episodes: number, latestUpdate: number) {
  return isEnd ? getString('app.string.cover_episode_info', episodes.toString()) :
  getString('app.string.cover_update_info', latestUpdate.toString())
}

function getCoverEpisodeStateText(isEnd: boolean) {
  return isEnd ? getString('app.string.cover_state_end') : getString('app.string.cover_state_update')
}

function getRankBackgroundColor(rankId?: number): Resource {
  switch (rankId) {
    case 1:
      return getColor('app.color.billboard_rank_top')
    case 2:
      return getColor('app.color.billboard_rank_next')
    case 3:
      return getColor('app.color.billboard_rank_third')
    default:
      return getColor('app.color.billboard_rank_other')
  }
}

@ComponentV2
export struct DramaCover {
  @Param @Require drama: DramaCoverVM
  @Param @Require index: number
  @Param @Require isVertical: boolean
  @Consumer('rank') selectedCategory: string = ''
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  @Builder
  episodeInfoBuilder(latestUpdate: number, episodes: number) {
    Column() {
      Text(getCoverEpisodeShowText(latestUpdate === episodes, episodes, latestUpdate))
        .padding({
          top: 1,
          right: 8,
          bottom: 1,
          left: 8
        })
        .borderRadius(14)
        .fontSize(fp2pxUtil(10))
        .fontColor(Color.White)
        .backgroundColor($r('sys.color.mask_tertiary'))
        .height(16)
    }
    .padding({
      right: 2, bottom: 2,
    })
    .height(18)
    .alignItems(HorizontalAlign.End)
  }

  build() {
    Column() {
      Row() {
        Column() {
          Stack() {
            Text(this.index.toString())
              .padding({
                top: 1,
                right: 8,
                bottom: 1,
                left: 8
              })
              .fontSize(fp2pxUtil(10))
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
              .borderRadius({
                topLeft: 8, bottomRight: 8
              })
              .backgroundColor(getRankBackgroundColor(this.index))
              .zIndex(100)
            Image(this.drama.imagePath)
              .width(78)
              .height(96)
              .borderRadius(8)
              .overlay(this.episodeInfoBuilder(this.drama.episodes, this.drama.latestUpdate),
                { align: Alignment.BottomEnd })
          }
          .alignContent(Alignment.TopStart)
        }

        Column() {
          Row() {
            Text(this.drama.title)
              .width(145)
              .maxLines(this.isVertical ? 1 : 2)
              .fontSize(this.fontModel.getFg(14))
              .fontWeight(FontWeight.Medium)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            if (this.selectedCategory === '热播榜') {
              Row() {
                Image(getMedia('app.media.ic_hot'))
                  .width(16)
                  .margin({ right: 2 })
                Text(this.index === 1 ? '980.4万' : this.index === 2 ? '916.4万' : '680.4万')
                  .fontSize(this.fontModel.getFg(12))
                  .fontWeight(500)
                  .fontColor($r('sys.color.font_primary'))
              }
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.End)
              .layoutWeight(1)
            } else if (this.selectedCategory === '飙升榜') {
              Row() {
                Image(getMedia('app.media.ic_ascent'))
                  .width(16)
                  .margin({ right: 2 })
                Text(this.index === 1 ? '1980.4%' : this.index === 2 ? '1046.4%' :
                  this.index === 3 ? '980.4%' : '680.4%')
                  .fontSize(this.fontModel.getFg(12))
                  .fontWeight(500)
                  .fontColor($r('sys.color.font_primary'))
              }
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.End)
              .layoutWeight(1)
            } else if (this.selectedCategory === '热搜榜') {
              Row() {
                Image(getMedia('app.media.hot_search'))
                  .width(16)
                  .margin({ right: 2 })
                Text(this.index === 1 ? '180.4万' : this.index === 2 ? '146.4万' :
                  this.index === 3 ? '80.4万' : this.index === 4 ? '63.7万' : '60.4万')
                  .fontSize(this.fontModel.getFg(12))
                  .fontWeight(500)
                  .fontColor($r('sys.color.font_primary'))
              }
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.End)
              .layoutWeight(1)
            }
          }
          .height(this.isVertical ? 19 : 38)
          .width('100%')
          .padding({ right: 16 })
          .margin({
            bottom: this.isVertical ? 0 : 10
          })
          .alignItems(VerticalAlign.Top)

          Row() {
            ForEach(this.drama.tags, (tag: string) => {
              Text(tag)
                .width(28)
                .height(16)
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .fontSize(fp2pxUtil(10))
                .fontWeight(400)
                .fontColor($r('sys.color.font_primary'))
                .textAlign(TextAlign.Center)
                .margin({ right: 8 })
                .borderRadius(4)
            }, (tag: string) => tag)
          }
          .height(16)
          .margin({ top: 8, bottom: 8 })
          .alignItems(VerticalAlign.Center)

          Row() {
            Text(this.drama.content)
              .maxLines(2)
              .fontSize(this.fontModel.getFg(12))
              .fontColor($r('sys.color.font_tertiary'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .height(38)
          .margin({ bottom: 8 })
          .padding({ right: 16 })

        }
        .layoutWeight(1)
        // .width(this.isVertical ? 244 : 84)
        .margin({
          left: this.isVertical ? 16 : 8
        })
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Top)
    }
    .alignItems(HorizontalAlign.Start)
  }
}