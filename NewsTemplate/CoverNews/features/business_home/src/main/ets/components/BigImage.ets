import { AppStorageV2 } from '@kit.ArkUI';
import { NewsItem, BreakpointModel, BreakpointNameEnum } from 'lib_common';

@ComponentV2
export struct BigImage {
  @Param newsItem: NewsItem = new NewsItem();
  @Event onItemTap: (newsItem: NewsItem) => void = () => {
  };
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Stack() {
      Image(this.newsItem.coverImageBg)
        .width('100%')
        .height('100%')
        .visibility(this.showBlurBg ? Visibility.Visible : Visibility.None)
      Stack({ alignContent: Alignment.Bottom }) {
        Image(this.newsItem.coverImage)
          .width(this.showBlurBg ? 'auto' : '100%')
          .height('100%')
          .objectFit(ImageFit.Cover)

        Column() {
          Text(this.newsItem.title)
            .fontSize($r('sys.float.Title_S'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Bold)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })

          Row({ space: 16 }) {
            Text(this.newsItem.source)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_on_primary'))

            Text(this.readCountText)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_on_primary'))
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({
          left: 16,
          right: 16,
          top: 50,
          bottom: this.breakPointModel.isTabVertical ? 96 : 56,
        })
        .backgroundImage($r('app.media.text_cover_bg'))
        .backgroundImageSize(ImageSize.Cover)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .onClick(() => {
      this.onItemTap(this.newsItem);
    })
  }

  @Computed
  get showBlurBg() {
    return this.newsItem.coverImageBg &&
    [BreakpointNameEnum.MD, BreakpointNameEnum.LG].includes(this.breakPointModel.currentBreakpoint);
  }

  @Computed
  get readCountText() {
    return this.newsItem.readCount < 10000 ? `${this.newsItem.readCount}千阅读` :
      `${(this.newsItem.readCount / 1000).toFixed(1)}万阅读`;
  }
}