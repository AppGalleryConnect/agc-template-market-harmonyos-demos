import {
  premiumInteractiveVideoData,
  VideoCard,
  videoDetail,
  VideoDetail,
} from '@ohos_agcit/children_education_datasource';
import { CommonConstants, IconAndCount, TagLabelCard, Title } from '@ohos_agcit/children_education_utils';

@Builder
export function PremiumInteractiveVideoListBuilder() {
  PremiumInteractiveVideoListView();
}


@ComponentV2
export struct PremiumInteractiveVideoListView {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  private videoArray: Array<VideoCard> = [];

  aboutToAppear(): void {
    this.videoArray = premiumInteractiveVideoData;
  }

  build() {
    NavDestination() {
      List({ space: 18 }) {
        ForEach(this.videoArray, (item: VideoCard) => {
          ListItem() {
            PremiumInteractiveVideoListItem({
              videoCard: item,
            });
          }
          .margin({
            bottom: $r('app.float.12vp')
          });

        });
      }
      .width(CommonConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .padding({
        right: '4%',
        left: '4%'
      })
    }
    .title(Title($r('app.string.interactive_section')))
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}


@ComponentV2
struct PremiumInteractiveVideoListItem {
  @Param @Once @Require videoCard: VideoCard;
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();

  build() {
    Column({ space: 10 }) {
      RelativeContainer() {
        Image(this.videoCard.imageUrl)
          .aspectRatio(1.78)
          .borderRadius(12)
          .id(CommonConstants.IMAGE);
        IconAndCount(CommonConstants.IMAGE, this.videoCard.isVip, this.videoCard.updateCount, this.videoCard.totalCount, '13%', '20%',
          '25%');
      }
      .width('auto')
      .height('auto')
      .onClick(() => {
        let detail: VideoDetail = videoDetail;
        detail.videoCard = this.videoCard;
        this.appPathStack.pushPathByName('VideoDetailListView', detail);
      });

      Row() {
        Text(this.videoCard.title);
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start);

      Row() {
        ForEach(this.videoCard.tags, (item: string) => {
          TagLabelCard(item);
        });
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start);
    }
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width(CommonConstants.FULL_PERCENT);
  }
}