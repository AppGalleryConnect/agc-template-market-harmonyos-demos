import { VideoPlayView } from './VideoPlayView';
import { VideoPlayData, VideoPlayDataSource } from '../datasource/VideoPlayDataSource';
import { PlayController } from '../controller/PlayController';
import { PlaySession } from '../controller/PlaySession';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display } from '@kit.ArkUI';

/**
 * 功能描述：
 * 1. 进入页面，播放第一个视频。上下滑动切换视频，点击视频可以控制视频的播放和暂停。
 *
 * 实现原理：
 * 1. 使用Swiper组件创建一个竖直的可上下滑动的框架
 * 2. Swiper组件结合LazyForEach使用，懒加载资源
 * 3. 在Swiper组件中使用Video组件承载视频
 *
 * @param videoPlayDataSource:视频播放数据,提供给lazy for each
 * @param contentBuilder：视频播放上面的图层内容
 *
 */
const TAG = '[VideoSwiper]'

// 视频划动组件
@ComponentV2
export struct VideoSwiper {
  // 短视频数据
  @Param @Require videoPlayDataSource: VideoPlayDataSource = new VideoPlayDataSource();
  // 当前视频的下标
  @Param @Once currentVideoIndex: number = 0;
  // 初始化当前视频的下标
  preVideoIndex: number = this.currentVideoIndex
  // 外部view
  @Param @Require contentBuilder: WrappedBuilder<[VideoPlayData, PlayController, PlaySession]>;
  // 播放控制器
  @Param inPage: string = 'Home'
  @Param playController: PlayController = new PlayController()
  @Event refresh: Function = () => {
  }
  @Event loadMore: Function = () => {
  }
  // 首视频标志
  @Local firstFlag: boolean = true;
  @Local isPageShow: boolean = false;
  @Local isLoadingMore: boolean = false;
  @Local refreshStatus: RefreshStatus = RefreshStatus.Inactive;
  @Local refreshing: boolean = false
  @Local refreshed: boolean = false
  @Local isHover: boolean = false
  private foldStatusChange: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    this.getHover();
  };
  @Local creaseRegion: number[] = []
  // Swiper组件控制器
  private swiperController: SwiperController = new SwiperController();
  //实时更新接续数据
  @Event updateContinueModel: (index: number) => void = (index: number) => {
  }

  aboutToDisappear(): void {
    try {
      display.off('foldStatusChange',this.foldStatusChange);
    } catch (exception) {
      hilog.error(0x0000, TAG, 'Failed to unregister callback. Code: ' + JSON.stringify(exception));
    }
  }

  aboutToAppear(): void {
    this.getHover()
    try {
      display.on('foldStatusChange', this.foldStatusChange);
    } catch (exception) {
      hilog.error(0x0000, TAG, 'Failed to register onFoldStatusChange callback. Code: ' + JSON.stringify(exception));
    }
    this.getFoldCreaseRegion();
    hilog.debug(0x0000, TAG, `data size:${this.videoPlayDataSource.totalCount()}`)
    this.playController.setSwiperController(this.swiperController)
    this.playController.curentIndex = this.currentVideoIndex
  }

  onPageShow(): void {
    hilog.debug(0x0000, TAG, 'onPageShow!');
    this.isPageShow = true;
  }

  getStatusText() {
    switch (this.refreshStatus) {
      case RefreshStatus.Drag:
        return $r('app.string.refresh');
      case RefreshStatus.OverDrag:
        return $r('app.string.load')
      case RefreshStatus.Refresh:
        return $r('app.string.loading')
      default:
        return ''
    }
  }

  @Builder
  getRefreshDisplay() {
    Row() {
      LoadingProgress()
        .size({ width: 40, height: 40 })
        .color($r('sys.color.icon_secondary'))
      Text(this.getStatusText())
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  getLoadMoreDisplay() {
    Row() {
      LoadingProgress()
        .size({ width: 40, height: 40 })
        .color($r('sys.color.icon_secondary'))
      Text($r('app.string.loading'))
        .fontSize(14)
        .fontColor(Color.White)
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack() {
      Refresh({ refreshing: $$this.refreshing, builder: this.getRefreshDisplay }) {
        Swiper(this.swiperController) { // 使用Swiper组件实现滑动轮播显示的能力
          LazyForEach(this.videoPlayDataSource, (item: VideoPlayData, index: number) => {
            VideoPlayView({
              creaseRegion: this.creaseRegion,
              isHover: this.isHover,
              playController: this.playController,
              curIndex: this.currentVideoIndex,
              index: index,
              firstFlag: this.firstFlag,
              isPageShow: true,
              firstLoaded: () => {
                this.firstFlag = false;
              },
              videoData: item,
              contentBuilder: this.contentBuilder,
              previewUri: item.getPic(),
              freshLoaded: () => {
                if (this.refreshed) {
                  this.playController.play();
                  this.refreshed = false
                }
              },
              inPage: this.inPage
            })
          },
            (item: VideoPlayData, index: number) => index + '__' + JSON.stringify(item)
          )
        }
        .cachedCount(this.firstFlag ? 0 : 2)
        .width('100%')
        .height('100%')
        .vertical(true)
        .loop(this.inPage === 'Home' ? true : false)
        .curve(Curve.Ease)
        .duration(300)
        .index(this.preVideoIndex)
        .indicator(false)
        .backgroundColor(Color.Black)
        .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
          hilog.debug(0x0000, TAG,
            `onAnimationStart index: ${index},  targetIndex:${targetIndex}, extraInfo: ${extraInfo}.`);
          this.currentVideoIndex = targetIndex;
          this.playController.curentIndex = targetIndex
          this.updateContinueModel(targetIndex)
        })
        // .onAnimationEnd((index: number, extraInfo: SwiperAnimationEvent) => {
        //   hilog.debug(0x0000, TAG, `onAnimationEnd index: ${index}, extraInfo: ${extraInfo}.`);
          // if (index === this.videoPlayDataSource.totalCount() - 1) {
          //   this.loadMoreData();
          // }
        // })
        // .onChange((index: number) => {
        //   hilog.debug(0x0000, TAG, `onChange index: ${index}.`);
        //   this.currentVideoIndex = index;
        //   this.playController.curentIndex = index
        // })
        .disableSwipe(this.playController.disableSwiper)
      }
      .onStateChange(async (value: RefreshStatus) => {
        this.refreshStatus = value
        if (value === RefreshStatus.Refresh) {
          await this.onRefresh();
        } else if (value === RefreshStatus.Done) {
          this.refreshing = false
        }
      })
      .pullDownRatio(this.playController.disableSwiper ? 0 : 1)

    }
    .width('100%')
    .height('100%')
  }

  async onRefresh() {
    try {
      this.refresh()
    } finally {
      this.refreshing = false
      this.refreshed = true
    }
  }

  async loadMoreData() {
    if (this.isLoadingMore) {
      return;
    } // 防止重复加载

    this.isLoadingMore = true;
    try {
      this.loadMore()
    } finally {
      this.isLoadingMore = false;
    }
  }

  getHover(){
    try {
      let orientation: display.Orientation = display.getDefaultDisplaySync().orientation;
      if (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_HALF_FOLDED && this.inPage === 'Detail' &&
        (orientation === display.Orientation.LANDSCAPE || orientation === display.Orientation.LANDSCAPE_INVERTED)
      ) {
        this.isHover = true;
        hilog.info(0x0000, TAG, `success in hover`);
      } else {
        this.isHover = false;
        hilog.info(0x0000, TAG, `fail in hover`);
      }
    } catch (error) {
      hilog.error(0x0000, TAG, `onFoldStatusChange catch error, code: ${error.code}, message: ${error.message}`);
    }
  }

  getFoldCreaseRegion() {
    try {
      if (display.isFoldable()) {
        let foldRegion: display.FoldCreaseRegion = display.getCurrentFoldCreaseRegion();
        let rect: display.Rect = foldRegion.creaseRects[0];
        // Height of the avoidance area in the upper half screen and height of the avoidance area.
        this.creaseRegion = [this.getUIContext().px2vp(rect.top), this.getUIContext().px2vp(rect.height)];
        AppStorage.setOrCreate('creaseRegion', this.creaseRegion);
      }
    } catch (error) {
      hilog.error(0x0000, TAG, `getFoldCreaseRegion catch error, code: ${error.code}, message: ${error.message}`);
    }
  }
}
