import { VideoCardDetail, VideoDetail } from '@ohos_agcit/children_education_datasource';
import {
  CommonConstants,
  IconAndCount,
  TimeControl,
  Title,
} from '@ohos_agcit/children_education_utils';
import { GlobalContext } from '@ohos_agcit/children_education_utils';

@Builder
export function AudioDetailBuilder() {
  AudioDetailListView();
}


@ComponentV2
export struct AudioDetailListView {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Local audioDetail: VideoDetail = {
    videoCard: {
      id: CommonConstants.EMPTY_STRING,
      title: CommonConstants.EMPTY_STRING,
      describe: CommonConstants.EMPTY_STRING,
      tags: [],
      videoType: 1,
      updateCount: 0,
      totalCount: 0,
      imageUrl: CommonConstants.EMPTY_STRING,
      isVip: false,
    },
    videoCardDetail: [],
  };

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row() {
            Column() {
              RelativeContainer() {
                Image(this.audioDetail.videoCard.imageUrl)
                  .borderRadius(5)
                  .margin('8vp')
                  .id(CommonConstants.IMAGE);
                IconAndCount(CommonConstants.IMAGE,
                  this.audioDetail.videoCard.isVip,
                  this.audioDetail.videoCard.updateCount,
                  this.audioDetail.videoCard.totalCount
                  , '25%', '50%', '60%');
              };
            }
            .width('30%');

            Column({ space: 10 }) {
              Text(this.audioDetail.videoCard.title)
                .fontSize(20)
                .fontWeight(FontWeight.Medium);
              Text(this.audioDetail.videoCard.describe)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontColor('#ff949191')
                .fontSize(12);
            }
            .width('68%')
            .alignItems(HorizontalAlign.Start);
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(130)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius(12)
          .shadow(ShadowStyle.OUTER_DEFAULT_SM);

          List({ space: 10 }) {
            ForEach(this.audioDetail.videoCardDetail, (item: VideoCardDetail, index: number) => {
              AudioListItem({
                audioItem: item,
                index: index,
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
                    GlobalContext.getContext().setObject(CommonConstants.GLOBAL_VIDEO_LIST, this.audioDetail);
                    let pathInfo: NavPathInfo = new NavPathInfo(CommonConstants.AUDIO_PLAY_PAGE, item);
                    this.appPathStack.pushDestination(pathInfo, true);
                  }
                });
            });
          }
          .alignListItem(ListItemAlign.Start)
          .margin({
            top: '10%',
          });
        }
        .margin({
          left: '4%',
          right: '4%',
        });
      }
      .scrollBar(BarState.Off);
    }
    .onReady((cxt: NavDestinationContext) => {
      this.audioDetail = cxt.pathInfo.param as VideoDetail;
    })
    .title(Title(this.audioDetail.videoCard.title))
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}

@ComponentV2
export struct AudioListItem {
  @Param @Once @Require audioItem: VideoCardDetail;
  @Param @Once @Require index: number;

  build() {
    Column() {
      if (this.index !== 0) {
        Divider()
          .width('85%')
          .padding({
            bottom: 10,
          });
      }

      Row() {
        Column() {
          Text(this.index + 1 + CommonConstants.EMPTY_STRING)
            .fontColor(Color.Gray);
        }
        .width('10%');

        Column({ space: 5 }) {
          Row() {
            Image(this.audioItem.isVip ? $r('app.media.icon_vip') : $r('app.media.icon_free'))
              .width('10%');
            Text(this.audioItem.title)
              .fontWeight(FontWeight.Regular)
              .fontColor(Color.Black)
              .fontSize(16)
              .padding({
                left: '2%',
              });
          };

          Row() {
            Image($r('app.media.icon_block'))
              .width('5%');
            Text('03:34')
              .fontColor(Color.Gray)
              .fontSize(10)
              .padding({
                left: '2%',
              });
          };
        }
        .alignItems(HorizontalAlign.Start)
        .width('90%');
      };
    };
  }
}