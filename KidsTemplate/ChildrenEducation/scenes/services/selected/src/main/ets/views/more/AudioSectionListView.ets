import { VideoCard, audioListData, VideoDetail, audioDetail } from '@ohos_agcit/children_education_datasource';
import { CommonConstants, IconAndCount, Title } from '@ohos_agcit/children_education_utils';

@Builder
export function AudioSectionListBuilder() {
  AudioSectionListView();
}


@ComponentV2
export struct AudioSectionListView {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  private audioList: Array<VideoCard> = [];

  aboutToAppear(): void {
    this.audioList = audioListData;
  }

  build() {
    NavDestination() {
      List({ space: 20 }) {
        ForEach(this.audioList, (item: VideoCard) => {
          ListItem() {
            AudioSectionListItem({
              imageUrl: item.imageUrl,
              isVip: item.isVip,
              updateCount: item.updateCount,
              totalCount: item.totalCount,
              title: item.title,
              describe: item.describe,
            })
              .onClick(() => {
                let detail: VideoDetail = audioDetail;
                detail.videoCard = item;
                this.appPathStack.pushPathByName('AudioDetailListView', detail);
              });
          };
        });
      }
      .scrollBar(BarState.Off)
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        right: '4%',
        left: '4%'
      })
    }
    .title(Title('音频故事专区'))
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}

@ComponentV2
struct AudioSectionListItem {
  @Param @Require imageUrl: string;
  @Param @Require isVip: boolean;
  @Param @Require updateCount: number;
  @Param @Require totalCount: number;
  @Param @Require title: string;
  @Param @Require describe: string;

  build() {
    Row() {
      Column() {
        RelativeContainer() {
          Image(this.imageUrl)
            .borderRadius(12)
            .id(CommonConstants.IMAGE);
          IconAndCount(CommonConstants.IMAGE, this.isVip, this.updateCount, this.totalCount, '30%', '45%', '50%');
        }
        .width('auto')
        .height('auto');
      }
      .width('40%')


      Column({ space: 10 }) {
        Text(this.title)
          .fontWeight(FontWeight.Medium)
          .fontSize(20);

        Text(this.describe)
          .fontSize(13)
          .fontColor('#ff817e7e')
          .textAlign(TextAlign.Start)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(3)
      }
      .width('60%')
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: 10,
      });
    };
  }
}
