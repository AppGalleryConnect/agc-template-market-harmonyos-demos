import {
  selectedPageData,
  SelectedPageData, VideoCard,
} from '@ohos_agcit/children_education_datasource';
import { CommonConstants, FeedTitle, TwoColumn, NoMoreTab } from '@ohos_agcit/children_education_utils';
import { AudioStoryZone } from '../components/AudioStoryZone';
import { Banner } from '../components/Banner';
import { HobbyCategory } from '../components/HobbyCategory';
import { PremiumVideo } from '../components/PremiumVideo';


@ComponentV2
export struct SelectedPage {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Local selectedPageData: SelectedPageData = selectedPageData;
  @Local premiumVideo : Array<VideoCard> = this.selectedPageData.premiumVideoZero;
  @Consumer('age') age: string = '0-3岁';

  @Monitor('age')
  onAgeChange() {
    if (this.age === '3-6岁') {
      this.premiumVideo = this.selectedPageData.premiumVideoThree;
    } else if (this.age === '6岁以上') {
      this.premiumVideo = this.selectedPageData.premiumVideoSix;
    } else if (this.age === '0-3岁') {
      this.premiumVideo = this.selectedPageData.premiumVideoZero;
    }
  }

  build() {
    Column() {
      List({ space: 30 }) {
        ListItem() {
          Banner({
            bannerArray: this.selectedPageData.bannerArray,
          });
        };

        ListItem() {
          HobbyCategory({
            hobbyCategory: this.selectedPageData.hobbyCategory,
          });
        };

        ListItemGroup({
          header: FeedTitle('app.media.feed_head_premium', '精品互动视频', () => {
            this.appPathStack.pushPathByName('PremiumInteractiveVideoListView', undefined);
          }),
        }) {
          PremiumVideo({
            premiumArray: this.premiumVideo,
          });
        };

        ListItemGroup({
          header: FeedTitle('app.media.feed_head_video', '热门动画榜',
            () => {
              this.appPathStack.pushPathByName('HotAnimationListView', undefined);
            }),
        }) {
          TwoColumn({
            videoCardArray: this.selectedPageData.hotAnimation
          });
        };

        ListItemGroup({
          header: FeedTitle('app.media.feed_head_audio', '音频故事专区', () => {
            this.appPathStack.pushPathByName('AudioSectionListView', undefined);
          }),
        }) {
          AudioStoryZone({
            audioStoryArray: this.selectedPageData.audioStory,
          });
        };

        ListItemGroup({
          header: FeedTitle('app.media.feed_head_video', '经典故事', () => {
            this.appPathStack.pushPathByName('HotAnimationListView', undefined);
          }),
        }) {
          TwoColumn({
            videoCardArray: this.selectedPageData.classicStory
          });
        };

        ListItemGroup({ header: NoMoreTab($r('app.string.reach_bottom')) }) {
        };
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT);
    };
  }
}