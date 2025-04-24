import { cartoonPageData } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, FeedTitle, TwoColumn, NoMoreTab,
  CommonOneColumn } from '@ohos_agcit/children_education_utils';
import { CoreButtons } from '../components/CoreButtons';

@ComponentV2
export struct CartoonPage {
  private cartoonPageData = cartoonPageData;
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();

  build() {
    Column() {
      List({ space: 16 }) {
        ListItem() {
          CoreButtons()
        }.padding({ bottom: 26 })

        ListItemGroup({
          header: FeedTitle('app.media.feed_head_video', '<超级汽车第四季>全52集',
            () => {
              this.appPathStack.pushPathByName('PremiumInteractiveVideoListView', undefined);
            })
        }) {
          CommonOneColumn({
            videoCard: this.cartoonPageData.superCar.videoCard
          })
            .padding({
              top: 10,
              right: '4%',
              left: '4%'
            })
        }
        ListItemGroup({
          header: FeedTitle('app.media.feed_head_video', '<多米益智乐园2>每周更新',
            () => {
              this.appPathStack.pushPathByName('PremiumInteractiveVideoListView', undefined);
            })
        }) {
          CommonOneColumn({
            videoCard: this.cartoonPageData.domiParadise.videoCard
          })
            .padding({
              top: 10,
              right: '4%',
              left: '4%'
            })
        }

        ListItemGroup({
          header: FeedTitle('app.media.feed_head_video', '趣味大百科',
            () => {
              this.appPathStack.pushPathByName('PremiumInteractiveVideoListView', undefined);
            })
        }){
          TwoColumn({
            videoCardArray: this.cartoonPageData.funEncyclopedia
          });

        }

        ListItem() {
          NoMoreTab($r('app.string.reach_bottom'))
        }
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .padding({ top: 10 })
    }
  }
}