import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { CommonConstants, RouterMap, RouterUtils, SettingModel, VideoLiveStatus } from 'lib_common'
import { BaseImage } from 'lib_widget';
import { VideoPipViewModel } from 'lib_av_details';
import { PiPWindowModel } from 'module_swipeplayer';
import { VideoNewsData } from '../models/VideoModel'

@ComponentV2
export struct LivestreamCard {
  @Param @Require cardData: VideoNewsData
  @Param liveStatus: VideoLiveStatus = VideoLiveStatus.EXPIRED;
  @Param imgBorderRadius: number = 8;
  @Param titleFontSize: number = 14;
  @Local prefixText: string = ''
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
  @Local pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;
  @Local videoPipViewModel: VideoPipViewModel = new VideoPipViewModel()

  aboutToAppear(): void {
    if (this.liveStatus === VideoLiveStatus.LIVE) {
      this.prefixText = '【正在直播】'
    }
  }

  async pushToDetailPage() {
    await this.videoPipViewModel.isRestPipController(this.cardData.id)
    const param: Record<string, VideoNewsData> = {
      'detailData': this.cardData,
    }
    RouterUtils.pushPathByName(RouterMap.LIVESTREAM_DETAIL_PAGE, param);
  }

  @Computed
  get badgeText() {
    if (this.liveStatus === VideoLiveStatus.FUTURE) {
      return '即将开始';
    }
    if (this.liveStatus === VideoLiveStatus.LIVE) {
      return '直播中';
    }
    if (this.liveStatus === VideoLiveStatus.EXPIRED) {
      return '精彩回放';
    }
    return '';
  }

  @Computed
  get badgeTextBg() {
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
    Column({ space: CommonConstants.SPACE_S }) {
      Stack({ alignContent: Alignment.TopEnd }) {
        BaseImage({
          url: this.cardData.coverUrl,
          imgRadius: this.imgBorderRadius,
          downloadWithoutWlan: this.settingInfo.network.downloadWithoutWlan,
        })
          .width(CommonConstants.FULL_PERCENT)
          .aspectRatio(16 / 9)

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

      Row() {
        Text(this.prefixText + this.cardData.title)
          .fontSize(this.titleFontSize)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(500)
          .lineHeight(21)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .constraintSize({ maxHeight: 42 })
      .alignItems(VerticalAlign.Top)
    }
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      this.pushToDetailPage()
    })
  }
}