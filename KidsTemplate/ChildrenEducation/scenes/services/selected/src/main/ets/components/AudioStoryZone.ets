import { audioDetail, VideoCard, VideoDetail } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, IconAndCount } from '@ohos_agcit/children_education_utils';

@ComponentV2
export struct AudioStoryZone {
  @Param audioStoryArray: Array<VideoCard> = [];
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();

  build() {
    List() {
      ForEach(this.audioStoryArray, (item: VideoCard) => {
        ListItem() {
          Column() {
            RelativeContainer() {
              Image(item.imageUrl)
                .borderRadius(8)
                .id(CommonConstants.IMAGE);
              IconAndCount(CommonConstants.IMAGE, item.isVip, item.updateCount, item.totalCount, '30%', '60%', '70%');
            }
            .height('auto')
            .width('auto');
          };
        }
        .padding({
          left: '5%',
          right: '5%',
        })
        .onClick(() => {
          let detail: VideoDetail = audioDetail;
          detail.videoCard = item;
          this.appPathStack.pushPathByName('AudioDetailListView', detail);
        });
      });
    }
    .lanes(3)
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: '10vp',
      left: '3.4%',
      right: '3.4%'
    })
  }
}