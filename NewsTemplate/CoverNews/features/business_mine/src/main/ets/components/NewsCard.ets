import { CommonConstants, NewsItem, RouterMap, RouterUtils, TimeUtils } from 'lib_common';

@ComponentV2
export struct NewsCard {
  @Require @Param newsInfo: NewsItem;
  @Param allowClick: boolean = true;

  build() {
    Row({ space: CommonConstants.SPACE_S }) {
      Image(this.newsInfo.coverImage)
        .width(96)
        .height(72)
        .borderRadius(8)

      Column({ space: CommonConstants.SPACE_XS }) {
        Text(this.newsInfo?.title)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Start)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row() {
          Text(this.newsInfo.source)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_tertiary'))
          Text(TimeUtils.formatDate(this.newsInfo.time))
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_tertiary'))
            .margin({
              left: CommonConstants.PADDING_S,
            })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .alignItems(VerticalAlign.Top)
    .onClick(() => {
      if (this.allowClick) {
        RouterUtils.pushPathByName(RouterMap.NEWS_DETAIL_PAGE, this.newsInfo.id);
      }
    })
  }
}