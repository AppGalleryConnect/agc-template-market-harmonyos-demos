import { AppStorageV2 } from '@kit.ArkUI';
import { DisplayModel, RouterMap } from 'common';
import { VideoModel } from 'video_common';
import { OfflineVideoDownload } from 'offline_video_download';
import { CommonConstants, VideoInfo } from 'offline_video_download/src/main/ets/CommonConstants';
import { phoneRouterControl } from 'oh_router';
import { OfflineVideoListPageBuilder } from './OfflineVideoListPage';

/**
 * @usage: 用于展示离线视频缓冲区域组件，显示离线视频列表和跳转到全部离线视频页面的入口。
 * 关键参数：videoState.isPlaying视频播放状态。
 * 包含if逻辑：当videoState.isPlaying为false时显示标题栏和全部入口。
 * @layout: 纵向排列。顶部为标题栏和全部入口（横向排列，两端对齐），下方为离线视频列表（纵向排列）。
 * @constraints:
 * @zhName: 离线视频缓冲视图
 * @fileType: component
 * @isGen: true
 * @subPage: OfflineVideoListPage
 * @component: OfflineVideoDownload
 */
@ComponentV2
export struct OfflineVideoView {
  @Local videoState: VideoModel = AppStorageV2.connect<VideoModel>(VideoModel, () => new VideoModel())!;
  @Local displayModel: DisplayModel = AppStorageV2.connect(DisplayModel, () => new DisplayModel())!;
  @Consumer('isScreenLand') isScreenLand: boolean = false;
  @Provider() isInPlayStatus: boolean = false;

  build() {
    Column() {
      if (!this.videoState.isPlaying) {
        Row() {
          Text('离线视频缓冲').fontSize(16).fontColor('rgba(255, 255, 255, 0.80)')
          Row() {
            Text('全部').fontSize(14).fontColor('rgba(255, 255, 255, 0.60)')
            Image($r('app.media.left_arrow')).width(10).height(17)
          }
          .onClick(() => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.OFFLINE_VIDEO_LIST_PAGE,
              builder: wrapBuilder(OfflineVideoListPageBuilder)
            })
          })
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ bottom: 20 })
      }
      if (CommonConstants.VIDEO_HTTPS_LISTS.length > 0) {
        List() {
          ForEach(CommonConstants.VIDEO_HTTPS_LISTS, (item: VideoInfo) => {
            ListItem() {
              Row() {
                // 视频组件
                OfflineVideoDownload({ videoInfo: item, isDarkMode: true })
                  .layoutWeight(1)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
          }, (item: VideoInfo) => item.id)
        }
        .width('100%')
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      } else {
        this.emptyDataBuilder()
      }
    }.padding({ top: this.isInPlayStatus ? 0 : 26, left: this.getPaddingH(), right: this.getPaddingH() })
  }

  getPaddingH() {
    if (this.isInPlayStatus) {
      return 0
    }
    if (this.displayModel.isExpanded) {
      return 24
    } else {
      return 16
    }
  }

  @Builder
  emptyDataBuilder() {
    Column() {
      Image($r('app.media.no_data_icon'))
        .width(50)
        .height(50)
      Text('暂无作品')
        .fontColor('#66FFFFFF')
        .fontSize(11)
        .margin({ top: 20 })
    }
    .width('100%')
    .margin({ top: 50 })
    .justifyContent(FlexAlign.Center)
  }
}