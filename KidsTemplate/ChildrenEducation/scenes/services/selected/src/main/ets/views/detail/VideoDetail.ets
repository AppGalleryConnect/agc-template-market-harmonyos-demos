import { VideoCardDetail, VideoDetail } from '@ohos_agcit/children_education_datasource';
import {
  CommonConstants,
  IconAndCount,
  TagLabelCard,
  TimeControl,
  Title,
} from '@ohos_agcit/children_education_utils';
import { GlobalContext } from '@ohos_agcit/children_education_utils';

@Builder
export function VideoDetailBuilder() {
  VideoDetailListView();
}


@ComponentV2
export struct VideoDetailListView {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Local videoDetail: VideoDetail = {
    videoCard: {
      id: CommonConstants.EMPTY_STRING,
      title: CommonConstants.EMPTY_STRING,
      describe: CommonConstants.EMPTY_STRING,
      tags: [],
      videoType: 0,
      updateCount: 0,
      totalCount: 0,
      imageUrl: CommonConstants.EMPTY_STRING,
      isVip: false,
    },
    videoCardDetail: [],
  };

  build() {
    NavDestination() {
      Column() {
        Row() {
          Column() {
            RelativeContainer() {
              Image(this.videoDetail.videoCard.imageUrl)
                .borderRadius(12)
                .margin('8vp')
                .id(CommonConstants.IMAGE);
              IconAndCount(CommonConstants.IMAGE,
                this.videoDetail.videoCard.isVip,
                this.videoDetail.videoCard.updateCount,
                this.videoDetail.videoCard.totalCount
                , '25%', '50%', '60%');
            };
          }
          .width('50%');

          Column({ space: 10 }) {
            Text(this.videoDetail.videoCard.title).fontWeight(FontWeight.Bold);
            Text(this.videoDetail.videoCard.describe)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontColor('#ffb8b1b1')
              .fontSize(12);

            Row() {
              ForEach(this.videoDetail.videoCard.tags, (item: string) => {
                TagLabelCard(item);
              });
            };
          }
          .width('50%')
          .alignItems(HorizontalAlign.Start);
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(130)
        .backgroundColor($r('sys.color.white'))
        .borderRadius(12)
        .shadow(ShadowStyle.OUTER_DEFAULT_SM)

        List({ space: 20 }) {
          ForEach(this.videoDetail.videoCardDetail, (item: VideoCardDetail, index ?: number) => {
            VideoListItem({
              title: item.title,
              imageUrl: item.imageUrl,
              isVip: item.isVip,
            })
              .onClick(() => {
                let vipInfo = GlobalContext.getContext().getObject(CommonConstants.IS_VIP) as boolean;
                if (item.isVip && !vipInfo) {
                  let pathInfo: NavPathInfo = new NavPathInfo(CommonConstants.VIP_PAGE_VIEW, item);
                  this.appPathStack.pushDestination(pathInfo, true);
                } else {
                  if (TimeControl.timeControl()) {
                    return;
                  }
                  GlobalContext.getContext().setObject(CommonConstants.GLOBAL_VIDEO_LIST, this.videoDetail);
                  let pathInfo: NavPathInfo = new NavPathInfo(CommonConstants.VIDEO_PLAY_PAGE, item);
                  this.appPathStack.pushDestination(pathInfo, true);
                }
              });
          });
        }
        .scrollBar(BarState.Off)
        .width('105%')
        .lanes(2)
        .alignListItem(ListItemAlign.Center)
        .listDirection(Axis.Vertical)
        .padding({
          top: 30,
        });
      }
      .padding({
        left: '4%',
        right: '4%',
      });

    }
    .onReady((cxt: NavDestinationContext) => {
      this.videoDetail = cxt.pathInfo.param as VideoDetail;
    })
    .title(Title('视频专辑'))
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}

@ComponentV2
struct VideoListItem {
  @Param title: string = CommonConstants.EMPTY_STRING;
  @Param imageUrl: string = CommonConstants.EMPTY_STRING;
  @Param isVip: boolean = false;

  build() {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(this.imageUrl)
          .width('90%')
          .aspectRatio(1.78)
          .borderRadius(10);
        Image(this.isVip ? $r('app.media.icon_vip_top_start') : $r('app.media.icon_free_top_start'))
          .width('20%')
      };

      Text(this.title)
        .fontWeight(FontWeight.Medium)
        .fontSize(16);
    }
    .alignItems(HorizontalAlign.Start);
  }
}