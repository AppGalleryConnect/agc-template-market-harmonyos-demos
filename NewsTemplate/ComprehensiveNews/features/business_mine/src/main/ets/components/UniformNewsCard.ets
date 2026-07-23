import { CommonConstants, RouterParams, RouterToNews, TextSpanInfo, TimeUtils } from 'lib_common';
import { NewsEnum, NewsModel } from 'lib_news_api';
import { Constants } from '../constants/Constants';

export interface UniformNewsStyle {
  bodyFg?: Length
  bodyFgColor?: ResourceColor
  imgRatio?: number
}

@ComponentV2
export struct UniformNewsCard {
  @Require @Param newsInfo: NewsModel;
  @Param showAuthorInfoTop: boolean = false;
  @Param showAuthorInfoBottom: boolean = true;
  @Param customStyle: UniformNewsStyle = {
    bodyFg: $r('sys.float.Body_L'),
    bodyFgColor: $r('sys.color.font_primary'),
    imgRatio: 1,
  };
  @BuilderParam operateBuilder: () => void;

  @Computed
  get title() {
    try {
      return (JSON.parse(this.newsInfo?.title || '[]') as TextSpanInfo[]).map(v => v.text).join('');
    } catch (e) {
      return this.newsInfo?.title || '';
    }
  }

  build() {
    Column({ space: CommonConstants.SPACE_S }) {
      Row({ space: CommonConstants.SPACE_S }) {
        Column({ space: CommonConstants.SPACE_XS }) {
          Text(this.title)
            .fontSize(this.customStyle.bodyFg ?? $r('sys.float.Body_L'))
            .fontColor(this.customStyle.bodyFgColor ?? $r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Row() {
            this.authorInfo()
          }
          .visibility(this.showAuthorInfoTop ? Visibility.Visible : Visibility.None)
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
          .width(Constants.NEWS_IMAGE_WIDTH / (this.customStyle.imgRatio ?? 1))
          .height(Constants.NEWS_IMAGE_HEIGHT / (this.customStyle.imgRatio ?? 1))
          .accessibilityGroup(true)
          .accessibilityLevel('no')
        } else if (this.imgUrl) {
          Image(this.imgUrl)
            .width(Constants.NEWS_IMAGE_WIDTH / (this.customStyle.imgRatio ?? 1))
            .height(Constants.NEWS_IMAGE_HEIGHT / (this.customStyle.imgRatio ?? 1))
            .borderRadius($r('app.float.small_radius'))
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .alignItems(VerticalAlign.Top)
      .onClick(() => {
        let routerParams: RouterParams<null> = {
          'type': this.newsInfo.type,
          'newsId': this.newsInfo.id,
          'surfaceUrl': this.videoUrl,
        }
        RouterToNews.pushToNewsDetails(routerParams)
      })

      Row() {
        Row({ space: CommonConstants.SPACE_S }) {
          this.authorInfo()
        }
        .accessibilityGroup(true)

        Blank()
        if (this.operateBuilder) {
          this.operateBuilder()
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .visibility(this.showAuthorInfoBottom ? Visibility.Visible : Visibility.None)
    }
  }

  @Builder
  authorInfo() {
    Text(this.newsInfo?.author.authorNickName)
      .fontSize($r('sys.float.Body_S'))
      .fontColor($r('sys.color.font_tertiary'))
    Text(TimeUtils.getDateDiff(this.newsInfo?.createTime))
      .fontSize($r('sys.float.Body_S'))
      .fontColor($r('sys.color.font_tertiary'))
      .margin({
        left: CommonConstants.PADDING_S,
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