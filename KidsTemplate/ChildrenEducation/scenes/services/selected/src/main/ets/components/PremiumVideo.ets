import { VideoCard, videoDetail, VideoDetail } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, IconLoc, TagLabelCard } from '@ohos_agcit/children_education_utils';


@ComponentV2
export struct PremiumVideo {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Param premiumArray: Array<VideoCard> = [];

  build() {
    List() {
      ForEach(this.premiumArray, (item: VideoCard, index: number) => {
        ListItem() {
          Column() {
            Row() {
              Stack({ alignContent: Alignment.TopStart }) {
                Image(item.imageUrl)
                  .width('33%')
                  .borderRadius(10)
                  .id(CommonConstants.IMAGE);
                Image($r('app.media.icon_vip_top_start'))
                  .width('10%')
              };

              Column({ space: 10 }) {
                Text(item.title)
                  .fontWeight(FontWeight.Medium)
                  .fontSize(14)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .align(Alignment.TopStart);

                Row() {
                  ForEach(item.tags, (tag: string) => {
                    TagLabelCard(tag);
                  });
                }
                .align(Alignment.BottomStart);
              }
              .alignSelf(ItemAlign.Center)
              .alignItems(HorizontalAlign.Start)
              .width('63%')
              .margin({ left: 10 });
            }
            .width('100%')

            Divider()
              .width('64%')
              .alignSelf(ItemAlign.End)
              .padding({
                top: '3%',
                bottom: index === this.premiumArray.length - 1 ? '0' : '5%',
              });
          };
        }
        .onClick(() => {
          let detail: VideoDetail = videoDetail;
          detail.videoCard = item;
          this.appPathStack.pushPathByName('VideoDetailListView', detail);
        });
      });
    }
    .padding({
      top: '12vp',
      left: '4%',
      right: '4%',
    });
  }
}