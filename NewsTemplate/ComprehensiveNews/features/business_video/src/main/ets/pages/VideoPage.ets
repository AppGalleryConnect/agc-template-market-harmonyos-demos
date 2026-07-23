import { CommonConstants, VideoType } from 'lib_common';
import { VideoViewModel } from '../viewmodels/VideoViewModel';
import { FollowPage } from '../views/FollowPage';
import { FeaturedPage } from '../views/FeaturedPage';
import { RecommendPage } from '../views/RecommendPage';
import { TabHeaderView } from '../components/TabHeaderView';
import { LivestreamPage } from '../views/LivestreamPage';
import { BroadcastPage } from '../views/BroadcastPage';
import { TelevisionPage } from '../views/TelevisionPage';

@Builder
export function VideoPageBuilder(videoTabIndex: number) {
  VideoPage({ videoTabIndex })
}

@ComponentV2({ freezeWhenInactive: true })
struct VideoPage {
  // 是否刷新页面，下滑滚动多个视频时，点击对应的tab，刷新页面
  @Provider() isRefreshPage: boolean = false;
  // 支持指定tabindex
  @Param videoTabIndex: number = VideoType.CHOICE;
  // 实例
  vm: VideoViewModel = new VideoViewModel();

  aboutToAppear(): void {
    // 进入指定的tabindex
    this.vm.onChangeTabIndex(this.videoTabIndex);
    // 执行index变化联动事件
    this.vm.onIndexChanged();
    // 监听videoTabIndex变化的事件
    this.vm.onTabIndexChange();
    // 视频评论出现时，tab头部隐藏
    this.vm.onTabHeaderShowChange();
  }

  aboutToDisappear(): void {
    this.vm.offTabIndexChange();
    this.vm.offTabHeaderShowChange();
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 内容
      this.tabContentView()
      // 导航栏
      TabHeaderView({
        tabNavs: this.vm.tabNavs,
        currentTabIndex: this.vm.currentTabIndex,
        showTabHeader: this.vm.showTabHeader,
        indicatorIndex: this.vm.indicatorIndex,
        onChangeTabIndex: (index: number) => {
          this.isRefreshPage = this.vm.currentTabIndex === index
          this.vm.onChangeTabIndex(index)
        },
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

  @Builder
  tabContentView() {
    Tabs({ controller: this.vm.tabController, index: this.vm.currentTabIndex }) {
      TabContent() {
        // 关注
        FollowPage({
          currentTabIndex: this.vm.indicatorIndex,
          index: VideoType.FOLLOW,
        })
      }

      TabContent() {
        // 精选
        FeaturedPage({
          currentTabIndex: this.vm.indicatorIndex,
          index: VideoType.CHOICE,
        })
      }

      TabContent() {
        // 推荐
        RecommendPage({
          currentTabIndex: this.vm.indicatorIndex,
          index: VideoType.RECOMMEND,
        })
      }

      TabContent() {
        // 直播
        LivestreamPage({
          currentTabIndex: this.vm.indicatorIndex,
          index: VideoType.LIVE,
        })
      }

      TabContent() {
        // 电视
        TelevisionPage({
          currentTabIndex: this.vm.indicatorIndex,
          index: VideoType.TELEVISION,
        })
      }

      TabContent() {
        // 广播
        BroadcastPage({
          currentTabIndex: this.vm.indicatorIndex,
          index: VideoType.BROADCAST,
        })
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .layoutWeight(1)
    .barHeight(0)
    .scrollable(!this.vm.videoExtraInfoModel.isDisplayChange)
    .animationDuration(100)
    .onAnimationStart((_index: number, targetIndex: number, _event: TabsAnimationEvent) => {
      this.vm.handleTabAnimationStart(_index, targetIndex);
    })
    .onChange((index: number) => {
      this.vm.currentTabIndex = index;
    })
  }
}