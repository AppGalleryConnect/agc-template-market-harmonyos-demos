import { getMedia } from '@agctemplate/resources'
import { AppStorageKeys, BreakPoint, BreakPointType, BreakPointValue, FontModel, fp2pxUtil } from '@agctemplate/widgets'
import { DramaCoverVM } from '../viewmodels/DramaCoverVM'
import { getCoverEpisodeShowText } from './DramaCover'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct DramaRecommendInfo {
  @Param @Require drama: DramaCoverVM
  @Param @Require onItemClick: Function
  @Param inPage: string = ''
  @Local currentBreakpoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(BreakPointValue.SM))!;
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
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.drama.imagePath)
          .transition(TransitionEffect.opacity(0.99))
          .height(new BreakPointType<number>({
            sm: 138,
            md: 210,
            lg: 249
          }).getValue(this.currentBreakpoint.value))//推荐短剧封面高度
          .width(new BreakPointType<number>({
            sm: 104,
            md: 159,
            lg: 189
          }).getValue(this.currentBreakpoint.value))//推荐短剧封面宽度
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
          .overlay(this.episodeInfoBuilder(this.drama.episodes, this.drama.latestUpdate),
            { align: Alignment.BottomEnd })

        if (this.inPage === 'new') {
          Image(getMedia('app.media.new'))
            .width(28)
            .height(16)
        } else if (this.drama.isVip === true) {
          Image(getMedia('app.media.vip'))
            .width(28)
            .height(16)
        }
      }
      .id('RecommendPanel'+this.drama.dramaId)

      Text(this.drama.title)
        .width(104)
        .maxLines(1)
        .fontSize(this.fontModel.getFg(14))
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: 8, bottom: 2 })
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text() {
        ForEach(this.drama.tags, (tag: string, index: number) => {
          if (index === 0) {
            Span(tag)
          } else {
            Span('·' + tag)
          }
        }, (tag: string) => tag)
      }
      .width(104)
      .height(16)
      .fontWeight(400)
      .fontColor($r('sys.color.font_tertiary'))
      .maxLines(1)
      .fontSize(fp2pxUtil(12))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      this.onItemClick(this.drama)
    })
  }
}