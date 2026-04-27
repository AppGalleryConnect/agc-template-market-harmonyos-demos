import { hilog } from '@kit.PerformanceAnalysisKit'
import { BarVM, VideoBackPressUtils, VideoModel } from 'video_common'
import { Constants, WindowUtils, TValueType } from 'common'
import { MinePage } from 'person'
import { VideoEditHomePage } from 'home'
import { WorkListPage } from 'work_list'
import { AppStorageV2 } from '@kit.ArkUI'
import { phoneRouterControl } from 'oh_router';

/**
 * @usage: tab 页面控制类，包括视频编辑、作品列表、个人中心
 * @layout:
 * @constraints: tab 页面控制类 包括视频编辑（video_edit_utils）、作品列表（work_list）、个人中心（person）。
 * 根据用户实际需求仅修改代码中 tabContentBuilder 调用，当前仅支持删除或调整tab项，
 * 以及修改索引从 0 开始并保证索引顺序，其他元素不允许修改。
 * @isGen: true
 * @fileType: tab
 * @zhName: 主页面
 * @domain: 视频
 * @image: screenshot/home.jpeg
 */

@Builder
export function HomePageBuilder(param: TValueType) {
  // 将路由参数透传到页面组件，避免 pageParams 恒为 null
  HomePage({ pageParams: param })
}

phoneRouterControl.registerPageBuilder('HomePage', wrapBuilder(HomePageBuilder))

@Builder
function videoEdit() {
  VideoEditHomePage()
}

@Builder
function worksList() {
  WorkListPage()
}

@Builder
function person() {
  MinePage()
}

const TAG = 'HomePage'

const videoEditBuilder: WrappedBuilder<[]> = wrapBuilder(videoEdit);
const worksListBuilder: WrappedBuilder<[]> = wrapBuilder(worksList);
const personBuilder: WrappedBuilder<[]> = wrapBuilder(person);

@ComponentV2
struct HomePage {
  @Local videoState: VideoModel = AppStorageV2.connect<VideoModel>(VideoModel, () => new VideoModel())!;
  @Local currentIndexTab: number = 0
  tabsController: TabsController = new TabsController()
  @Param pageParams: TValueType = null
  @Provider() isScreenLand: boolean = false;

  @Builder
  tabBuilder(title: Resource, index: number, whiteImg: Resource, blackImg: Resource, selectedImg: Resource) {
    Column() {
      Image(this.currentIndexTab === 0 ? whiteImg : this.currentIndexTab === index ? selectedImg : blackImg)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(title)
        .margin({ top: 4 })
        .fontSize(10)
        .fontColor(this.currentIndexTab === 0 ? '#D9FFFFFF' : '#D9000000')
    }.justifyContent(FlexAlign.Center)
    .height(52)
    .width('100%')
    .onClick(() => {
      this.currentIndexTab = index;
    })
  }

  @Builder
  tabContentBuilder(text: Resource,
    index: number,
    whiteImg: Resource,
    blackImg: Resource,
    selectedImg: Resource,
    builder: WrappedBuilder<[Object]> | WrappedBuilder<[]>,
    statusColor: string = '#ffffffff') {
    TabContent() {
      Stack() {
        (builder as WrappedBuilder<[]>).builder()
      }
      .height('100%')
    }.onWillShow(() => {
      BarVM.instance.setStatusFontColor(statusColor)
    })
    .backgroundColor(Color.White)
    .tabBar(this.tabBuilder(text, index, whiteImg, blackImg, selectedImg))
  }

  aboutToAppear(): void {
    WindowUtils.getMainWindow().setWindowSystemBarProperties({ statusBarContentColor: '#FFFFFF' })
    // 视频导出成功后，切换到工作页
    this.getUIContext().getHostContext()?.eventHub.on('showWorkListTab', () => {
      hilog.info(0x0000, TAG, 'export success show work list tab 1');
      this.currentIndexTab = 1;
    });
  }

  build() {
    NavDestination() {
      Tabs({
        barPosition: BarPosition.End,
        index: $$this.currentIndexTab,
        controller: this.tabsController
      }) {
        this.tabContentBuilder($r('app.string.video_edit'),
          Constants.TAB_INDEX_ZERO, $r('app.media.video_edit_tab_active'), $r('app.media.video_edit_tab_black'),
          $r('app.media.video_edit_tab_active'), videoEditBuilder,
          '#ffffffff')
        this.tabContentBuilder($r('app.string.video_works'),
          Constants.TAB_INDEX_ONE, $r('app.media.works_tab_white'), $r('app.media.works_tab_black'),
          $r('app.media.works_tab_active'), worksListBuilder, '#ff000000')
        this.tabContentBuilder($r('app.string.person'),
          Constants.TAB_INDEX_TWO, $r('app.media.person_tab_white'), $r('app.media.person_tab_black'),
          $r('app.media.person_tab_active'), personBuilder, '#ff000000')
      }
      .clip(true)
      .width('100%')
      .backgroundColor(this.currentIndexTab === 0 ? '#1C1C1C' : '#FFFFFF')
      .barHeight(this.videoState.isPlaying ? 0 : 50)
      .barMode(BarMode.Fixed)
      .padding({
        bottom: this.isScreenLand ? 0 : BarVM.instance.aiBarH
      })
      .animationDuration(0)
      .scrollable(false)
      .onAnimationStart((targetIndex: number) => {
        this.currentIndexTab = targetIndex;
      })
    }
    .onBackPressed(() => {
      let res = VideoBackPressUtils.clickBack()
      if (res) {
        return true
      }
      if (!this.isScreenLand) {
        return false
      }
      return false
    })
    .hideTitleBar(true)
  }
}
