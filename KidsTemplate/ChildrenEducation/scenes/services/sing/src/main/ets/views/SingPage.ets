import { singSongPageData } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, FeedTitle, TwoColumn, NoMoreTab } from '@ohos_agcit/children_education_utils';

@ComponentV2
export struct SingPage {
  private singSongPageData = singSongPageData;
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();

  build() {
    Column() {
      List({ space: 30 }) {

        ListItemGroup({
          header: FeedTitle('app.media.feed_head_video', '律动儿歌',() => {
          this.appPathStack.pushPathByName('HotAnimationListView', undefined);
        })
        }) {
          TwoColumn({
            videoCardArray: this.singSongPageData.childrenSong,
          });
        };

        ListItemGroup({
          header: FeedTitle('app.media.feed_head_video', '经典童谣', () => {
            this.appPathStack.pushPathByName('HotAnimationListView', undefined);
          }),
        }) {
          TwoColumn({
            videoCardArray: this.singSongPageData.childrenSong,
          });
        };

        ListItem() {
          NoMoreTab($r('app.string.reach_bottom'));
        };
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT);
    };
  }
}