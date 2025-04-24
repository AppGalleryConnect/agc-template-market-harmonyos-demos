import { VideoCard, VideoDetail, videoDetail } from '@ohos_agcit/children_education_datasource';
import { CommonConstants } from '../constants/CommonConstants';
import { IconAndCount } from './IconAndCount';
import { TagLabelCard } from './TagLabelCard';

@ComponentV2
export struct TwoColumn {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Param @Once @Require videoCardArray: Array<VideoCard>;

  build() {
    List({ space: '16vp' }) {
      ForEach(this.videoCardArray, (item: VideoCard) => {
        ListItem() {
          Column() {
            RelativeContainer() {
              Image(item.imageUrl)
                .aspectRatio(1.78)
                .borderRadius(10)
                .id(CommonConstants.IMAGE)
                .zIndex(0);
              IconAndCount(CommonConstants.IMAGE, item.isVip, item.updateCount, item.totalCount, '20%', '45%', '50%');
            }
            .height('auto')
            .width('auto');

            Column({ space: 4 }) {
              Text(item.title)
                .textAlign(TextAlign.Start)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
                .fontSize('14fp')
                .width(CommonConstants.FULL_PERCENT)
                .fontWeight(FontWeight.Medium);
              Text(item.describe)
                .textAlign(TextAlign.Start)
                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontSize('12fp')
                .width(CommonConstants.FULL_PERCENT);
            }
            .padding({ top: '8vp' });
          };
        }
        .padding({
          left: '4%',
          right: '4%'
        })
        .onClick(() => {
          let detail: VideoDetail = videoDetail;
          detail.videoCard = item;
          this.appPathStack.pushPathByName('VideoDetailListView', detail);
        });
      });
    }
    .lanes(2)
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: '10vp',
      left: '3%',
      right: '3%',
    });
  }
}

@ComponentV2
export struct CommonOneColumn {
  @Param @Once @Require videoCard: VideoCard;
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();

  build() {
    Column({ space: 10 }) {
      RelativeContainer() {
        Image(this.videoCard.imageUrl)
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
        Text(this.videoCard.title)
          .fontWeight(FontWeight.Bold)
          .freeze(true)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Blank();
        ForEach(this.videoCard.tags, (item: string) => {
          TagLabelCard(item);
        });
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceAround);

      Row() {
        Text(this.videoCard.describe)
          .fontSize(12)
          .fontColor('#ff969191');
      }.width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start);
    };
  }
}