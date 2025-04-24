import { cartoonPageData, videoDetail, VideoDetail } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, IconLoc, PlateType, TagLabelCard } from '@ohos_agcit/children_education_utils';

@ComponentV2
export struct SingStory {
  @Param @Once @Require singStory: Array<VideoDetail>;
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Local textWidth: number = 0;

  build() {
    List() {
      ForEach(this.singStory, (item: VideoDetail, index: number) => {
        ListItem() {
          Column() {
            Row() {
              RelativeContainer() {
                Image(item.videoCard.imageUrl)
                  .width('35%')
                  .borderRadius(10)
                  .id(CommonConstants.IMAGE);
                IconLoc(CommonConstants.IMAGE, item.videoCard.isVip, '10%');
              }
              .width('auto')
              .height('auto');

              Column() {
                Row() {
                  Text(item.videoCard.plateType)
                    .fontSize(10)
                    .fontWeight(FontWeight.Regular)
                    .fontColor('#53B5FF')
                    .borderColor('#53B5FF')
                    .borderWidth(1)
                    .position({ x: 0, y: 4 })
                    .padding({
                      top: '1vp',
                      bottom: '1vp',
                      left: '4vp',
                      right: '4vp',
                    })
                    .borderRadius(5)
                    .onAreaChange((oldValue, newValue: Area) => {
                      this.textWidth = Number(newValue.width);
                    });

                  Text(item.videoCard.title)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(2)
                    .fontWeight(FontWeight.Bold)
                    .fontSize(14)
                    .textIndent(this.textWidth + 5)
                    .lineHeight('22vp');
                }

                Blank()

                Row() {
                  ForEach(item.videoCard.tags, (tag: string) => {
                    TagLabelCard(tag);
                  });
                }
                .align(Alignment.BottomStart);
              }
              .layoutWeight(1)
              .height(100)
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 10, top :'4%', bottom:'4%' });
            };

            Divider()
              .width('62%')
              .alignSelf(ItemAlign.End);
          };

        }
        .onClick(() => {
          item.videoCardDetail = videoDetail.videoCardDetail;
          this.appPathStack.pushPathByName('VideoDetailListView', item);
        });
      });
    }
    .padding({
      left: '4%',
      right: '4%',
    });
  }
}