import { PersistenceV2 } from '@kit.ArkUI';
import { CommonConstants, RouterMap, RouterUtils, SettingModel, VideoLiveStatus } from 'lib_common';
import { NewsModel } from 'lib_news_api';
import { VideoPipViewModel } from 'lib_av_details';
import { VideoNewsData } from '../models/VideoNewsData';

@ComponentV2
export struct LiveReservationCard {
  @Require @Param reservationInfo: NewsModel;
  @Param refreshCard: boolean = false;
  @Event refreshList: () => void = () => {
  };
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
  @Local videoPipViewModel: VideoPipViewModel = new VideoPipViewModel()
  @Local liveStatus: VideoLiveStatus = VideoLiveStatus.FUTURE;

  aboutToAppear(): void {
    this.handleLiveStatus();
  }

  @Monitor('refreshCard')
  onRefresh() {
    if (this.refreshCard) {
      this.handleLiveStatus();
    }
  }

  handleLiveStatus() {
    const now = Date.now();
    const liveStartTime = this.reservationInfo.liveStartTime;
    const liveEndTime = this.reservationInfo.liveEndTime;
    if (liveStartTime && liveStartTime > Date.now()) {
      this.liveStatus = VideoLiveStatus.FUTURE;
    } else if (liveStartTime && liveStartTime <= now && liveEndTime && liveEndTime > now) {
      this.liveStatus = VideoLiveStatus.LIVE;
    } else {
      this.liveStatus = VideoLiveStatus.EXPIRED;
    }
  }

  @Computed
  get badgeText(): string {
    if (this.liveStatus === VideoLiveStatus.FUTURE) {
      return '即将开始';
    }
    if (this.liveStatus === VideoLiveStatus.LIVE) {
      return '直播中';
    }
    if (this.liveStatus === VideoLiveStatus.EXPIRED) {
      return '查看回放';
    }
    return '';
  }

  @Computed
  get badgeTextBg(): ResourceColor {
    if (this.liveStatus === VideoLiveStatus.FUTURE) {
      return $r('app.color.app_theme');
    }
    if (this.liveStatus === VideoLiveStatus.LIVE) {
      return $r('sys.color.warning');
    }
    if (this.liveStatus === VideoLiveStatus.EXPIRED) {
      return 'rgba(0, 0, 0, 0.4)';
    }
    return Color.Transparent;
  }

  build() {
    Row({ space: CommonConstants.SPACE_M }) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.reservationInfo.coverUrl)
          .width(96)
          .height(54)
          .borderRadius(8)
          .clip(true)
          .objectFit(ImageFit.Cover)

        Row({ space: 2 }) {
          Image($r('app.media.ic_live'))
            .width(12)
            .height(12)
            .visibility(this.liveStatus === VideoLiveStatus.LIVE ? Visibility.Visible : Visibility.None)
          Text(this.badgeText)
            .fontSize(10)
            .fontColor(Color.White)
            .lineHeight(13)
        }
        .padding({
          left: 8,
          top: 3,
          right: 8,
          bottom: 3,
        })
        .borderRadius({
          topLeft: 2,
          bottomLeft: 14,
          topRight: 14,
          bottomRight: 2,
        })
        .backgroundColor(this.badgeTextBg)
        .offset({ top: 2, right: 2 })
      }

      Text(this.reservationInfo.title)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .fontSize(16 * this.settingInfo.fontSizeRatio)
        .maxLines(2)
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
    }
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .padding(CommonConstants.PADDING_M)
    .borderRadius(16)
    .onClick(async () => {
      const videoNewsData = new VideoNewsData(this.reservationInfo);
      await this.videoPipViewModel.isRestPipController(videoNewsData.id)
      const param: Record<string, VideoNewsData> = {
        'detailData': videoNewsData,
      }
      RouterUtils.pushPathByName(RouterMap.LIVESTREAM_DETAIL_PAGE, param, () => {
        this.refreshList();
      });
    })
  }
}