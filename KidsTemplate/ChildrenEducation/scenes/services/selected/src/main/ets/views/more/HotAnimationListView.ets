import { VideoCard, hotAnimationData } from '@ohos_agcit/children_education_datasource';
import { CommonConstants,
  CommonOneColumn,
  Title } from '@ohos_agcit/children_education_utils';

@Builder
export function HotAnimationBuilder() {
  HotAnimationListView();
}



@ComponentV2
struct HotAnimationListView {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  private hotAnimationArray: Array<VideoCard> = [];

  aboutToAppear(): void {
    this.hotAnimationArray = hotAnimationData;
  }

  build() {
    NavDestination() {
      List({ space: 18 }) {
        ForEach(this.hotAnimationArray, (item: VideoCard) => {
          ListItem() {
            CommonOneColumn({
              videoCard: item
            })
          }
          .margin({
            bottom: $r('app.float.12vp')
          });
        });
      }
      .width(CommonConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .padding({
        right: '4%',
        left: '4%'
      })
    }
    .title(Title('视频专辑'))
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}