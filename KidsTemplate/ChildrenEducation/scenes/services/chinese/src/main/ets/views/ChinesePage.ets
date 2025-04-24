import { chinesePageData } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, FeedTitle, TwoColumn, NoMoreTab } from '@ohos_agcit/children_education_utils';
import { SingStory } from '../components/SingStory';

@ComponentV2
export struct ChinesePage {
  private chinesePageData = chinesePageData;
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();

  build() {
    Column() {
      List({ space: 30 }) {
        ListItemGroup({
          header: FeedTitle('app.media.feed_head_premium', '听故事 学叙事', () => {
            this.appPathStack.pushPathByName('PremiumInteractiveVideoListView', undefined);
          }),
        }) {
          SingStory({
            singStory: this.chinesePageData.singStory,
          });
        };

        ListItemGroup({
          header: FeedTitle('app.media.feed_head_premium', '三字经 磨耳朵', () => {
            this.appPathStack.pushPathByName('PremiumInteractiveVideoListView', undefined);
          }),
        }) {
          TwoColumn({
            videoCardArray: this.chinesePageData.threeCharacter,
          });
        };

        ListItem() {
          NoMoreTab($r('app.string.reach_bottom'));
        };
      }
      .scrollBar(BarState.Off);
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT);
  }
}