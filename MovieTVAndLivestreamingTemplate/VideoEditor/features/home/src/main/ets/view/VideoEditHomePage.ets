import { VideoModel } from 'video_common';
import { VideoEditHomeVM } from '../viewmodel/VideoEditHomeVM';
import { OfflineVideoView } from './OfflineVideoView';
import { AppStorageV2 } from '@kit.ArkUI';
import { DraftVideoComponent } from '../components/DraftVideoComponent'
import { DisplayModel, BreakpointModel } from 'common';
import { VideoEditDetailVM } from 'video_edit';

/**
 * @usage: 用于展示视频编辑应用的主页面。提供视频选择入口和创作功能，支持从相册选择视频进行编辑处理
 * @layout: 页面整体采用垂直布局（Column），居中显示视频添加按钮和创作提示文本，采用渐变背景样式提升视觉效果。
 * @constraints: videoState.isPlaying 控制页面显示状态，当视频播放时隐藏创作入口；vm.openVideoAlbum
 * 方法用于打开视频相册选择功能
 * @zhName: 视频编辑首页
 * @fileType: page
 * @isGen: true
 * @modifiable: 离线视频缓冲、作品草稿功能可供选择，需要根据用户的需求去删除。
 * @subPage: VideoEditDetailPage
 * @image: screenshot/home_modifiable.png
 * @domain: 视频
 * @component: DraftVideoComponent, OfflineVideoView
 */

@ComponentV2
export struct VideoEditHomePage {
  @Local videoState: VideoModel = AppStorageV2.connect<VideoModel>(VideoModel, () => new VideoModel())!;
  @Local selectedVideoUri: string = ''
  @Local vm: VideoEditHomeVM = new VideoEditHomeVM()
  @Local displayModel: DisplayModel = AppStorageV2.connect(DisplayModel, () => new DisplayModel())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  private swiperController: SwiperController = new SwiperController();

  aboutToAppear(): void {
    this.vm.init()
  }

  getPaddingH() {
    if (this.displayModel.isExpanded) {
      return 24
    } else {
      return 16
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (!this.videoState.isPlaying) {
            Stack() {
              Swiper(this.swiperController) {
                LazyForEach(this.vm.swiperData, () => {
                  Image(this.vm.getSwiperImg())
                    .width('100%')
                    .height(200)
                    .objectFit(ImageFit.Cover)
                }, (item: Resource) => JSON.stringify(item) + new Date().getTime())
              }
              .displayCount(1, true)
              .autoPlay(true)
              .interval(4000)
              .loop(true)
              .duration(1000)
              .itemSpace(10)
            }

            Column({ space: 10 }) {
              Image($r('app.media.icon_add_video'))
                .width('35')
                .height('35')
              Text('开始创作')
                .fontSize('16')
                .fontColor('#FFFFFF')
            }
            .width('calc(100% - ' + this.getPaddingH() * 2 + 'vp)')
            .height('100')
            .borderRadius('15')
            .margin({top : 12})
            .linearGradient(this.vm.gradientColor)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              VideoEditDetailVM.instance.showBottomViewFlag = false
              this.vm.openVideoAlbum(this.getUIContext(),this.selectedVideoUri)
            })

            // 作品草稿
            DraftVideoComponent()
          }
          // 离线视频缓冲
          OfflineVideoView()
        }
        .width('100%')
        .padding({ bottom: this.vm.displayModel.isLandscape ? 0 : 16 })
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .width('100%')
    }
    .hideTitleBar(true)
    .backgroundColor('#0D0C11')
  }
}