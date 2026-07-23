import { CommonConstants, RouterParams, RouterToNews, TimeUtils } from 'lib_common';
import { NewsEnum, NewsResponse } from 'lib_news_api';

@ComponentV2
export struct UniformNews {
  @Require @Param newsInfo: NewsResponse;
  @Param fontSizeRatio: number = 1;

  build() {
    Row({ space: CommonConstants.SPACE_M }) {
      Column({ space: CommonConstants.SPACE_XS }) {
        Text(this.newsInfo.title)
          .fontSize(16 * this.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(TimeUtils.getDateDiff(this.newsInfo.createTime))
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_tertiary'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.videoUrl) {
        RelativeContainer() {
          Image(this.videoUrl)
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .borderRadius($r('app.float.small_radius'))
          Image($r('app.media.ic_public_video_play'))
            .width($r('app.float.normal_img_size'))
            .aspectRatio(1)
            .draggable(false)
            .alignRules({
              center: { anchor: '__container__', align: VerticalAlign.Center },
              middle: { anchor: '__container__', align: HorizontalAlign.Center },
            })
          Row() {
            Text(TimeUtils.handleDuration(this.newsInfo.videoDuration))
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_on_primary'))
          }
          .backgroundColor($r('app.color.video_duration_bg'))
          .borderRadius($r('app.float.xs_radius'))
          .padding({
            top: CommonConstants.PADDING_XXS,
            bottom: CommonConstants.PADDING_XXS,
            left: CommonConstants.PADDING_XS,
            right: CommonConstants.PADDING_XS,
          })
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            right: { anchor: '__container__', align: HorizontalAlign.End },
          })
          .offset({ x: -4, y: -4 });
        }
        .width(96)
        .height(72)
        .accessibilityGroup(true)
        .accessibilityLevel('no')
      } else if (this.imgUrl) {
        Image(this.imgUrl)
          .width(96)
          .height(72)
          .borderRadius($r('app.float.small_radius'))
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(VerticalAlign.Top)
    .padding({
      top: CommonConstants.PADDING_M,
      bottom: CommonConstants.PADDING_M,
    })
    .onClick(() => {
      let routerParams: RouterParams<null> = {
        'type': this.newsInfo.type,
        'newsId': this.newsInfo.id,
        'authorId': this.newsInfo.author.authorId,
        'surfaceUrl': this.videoUrl,
      }
      RouterToNews.pushToNewsDetails(routerParams)
    })
  }

  @Computed
  get imgUrl() {
    if (this.newsInfo?.postImgList?.length) {
      return this.newsInfo.postImgList[0].picVideoUrl || '';
    }
    return '';
  }

  @Computed
  get videoUrl() {
    if (this.newsInfo?.type === NewsEnum.Video) {
      return this.newsInfo?.coverUrl;
    }
    if (this.newsInfo?.postImgList?.length) {
      return this.newsInfo.postImgList[0].surfaceUrl || '';
    }
    return '';
  }
}