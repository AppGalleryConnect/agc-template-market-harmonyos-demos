import { VideoCard, VideoDetail, videoDetail } from '@ohos_agcit/children_education_datasource';
import { CommonConstants } from '@ohos_agcit/children_education_utils';

@ComponentV2
export struct HobbyCategory {
  @Param @Once @Require hobbyCategory: Array<VideoCard>;
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      RelativeContainer() {
        Image($r('app.media.hobby_background_1'))
          .id(CommonConstants.IMAGE)
          .borderRadius('8');

        Text(this.hobbyCategory[0].title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .alignRules({
            left: { anchor: CommonConstants.IMAGE, align: HorizontalAlign.Start },
          })
          .padding({
            left: '15',
            top: '30',
          });

        Image($r('app.media.hobby_icon_1'))
          .width('35%')
          .alignRules({
            bottom: { anchor: CommonConstants.IMAGE, align: VerticalAlign.Bottom },
            right: { anchor: CommonConstants.IMAGE, align: HorizontalAlign.End },
          })
          .padding({
            bottom: '8%',
            right: '10%',
          });
      }
      .width('auto')
      .height('auto')
      .margin({
        right: '6vp',
      })
      .onClick(() => {
        let detail: VideoDetail = videoDetail;
        detail.videoCard = this.hobbyCategory[0];
        this.appPathStack.pushPathByName('VideoDetailListView', detail);
      });

      RelativeContainer() {
        Image($r('app.media.hobby_background_2'))
          .id(CommonConstants.IMAGE)
          .borderRadius('8');

        Text(this.hobbyCategory[1].title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .alignRules({
            left: { anchor: CommonConstants.IMAGE, align: HorizontalAlign.Start },
          })
          .padding({
            left: '15',
            top: '30',
          });

        Image($r('app.media.hobby_icon_2'))
          .width('35%')
          .alignRules({
            bottom: { anchor: CommonConstants.IMAGE, align: VerticalAlign.Bottom },
            right: { anchor: CommonConstants.IMAGE, align: HorizontalAlign.End },
          })
          .padding({
            bottom: '8%',
            right: '10%',
          });
      }
      .width('auto')
      .height('auto')
      .margin({
        left: '6vp',
      })
      .onClick(() => {
        let detail: VideoDetail = videoDetail;
        detail.videoCard = this.hobbyCategory[1];
        this.appPathStack.pushPathByName('VideoDetailListView', detail);
      });
    }
    .margin({
      left: '4%',
      right: '4%',
    })
    .height(80);
  }
}