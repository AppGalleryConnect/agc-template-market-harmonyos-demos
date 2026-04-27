import { common } from '@kit.AbilityKit';
import { Constants, DisplayModel } from 'common';
import { WorkListPageVM } from '../viewmodel/WorkListPageVM';
import { VideoGrid } from '../components/VideoGrid';
import { BarVM } from 'video_common';
import { AppStorageV2 } from '@kit.ArkUI';

/**
 * @usage: 用于展示工作列表页面。包含"视频作品"和"草稿"两个标签页，用于管理和展示用户的视频作品和草稿内容
 * @layout: 页面整体采用垂直布局（Column），使用Tabs组件实现标签切换，
 * 每个TabContent包含VideoGrid组件用于网格展示视频列表。
 * @constraints: vm.currentTabIndex 控制当前选中的标签页索引；vm.tabsController 用于标签页切换控制；
 * finishList 和 draftList 分别存储完成作品和草稿数据
 * @zhName: 工作列表
 * @fileType: page
 * @isGen: true
 * @domain: 视频
 * @image: screenshot/work.jpeg
 * @subPage: WorkDetailPage
 * @component: VideoGrid
 */
@ComponentV2
export struct WorkListPage {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  vm: WorkListPageVM = WorkListPageVM.instance;
  @Local displayModel: DisplayModel = AppStorageV2.connect(DisplayModel, () => new DisplayModel())!;

  async aboutToAppear() {
    // 初始化数据
    this.vm.init(this.context);
  }

  @Builder
  tabBuilder(title: string, index: number) {
    Text(title)
      .fontSize(16)
      .fontWeight(this.vm.currentTabIndex === index ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.vm.currentTabIndex === index ? '#D9000000' : '#FF9AA0AF')
      .padding({ right: 16 })
      .animation({
        duration: 200,
        curve: Curve.EaseInOut
      })
      .onClick(() => {
        this.vm.currentTabIndex = index;
        this.vm.tabsController.changeIndex(this.vm.currentTabIndex);
      })
  }

  getPaddingH() {
    if (this.displayModel.isExpanded) {
      return 26
    } else {
      return 16
    }
  }


  build() {
    Column() {
      Tabs({
        barPosition: BarPosition.Start,
        controller: this.vm.tabsController,
        barModifier: this.vm.tabBarModifier.align(Alignment.Start)
      }) {
        TabContent() {
          VideoGrid({ works: this.vm.finishList });
        }.tabBar(this.tabBuilder('视频作品', Constants.TAB_INDEX_ZERO))

        TabContent() {
          VideoGrid({ works: this.vm.draftList });
        }.tabBar(this.tabBuilder('草稿', Constants.TAB_INDEX_ONE))
      }
      .vertical(false)
      .barMode(BarMode.Scrollable)
      .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
        if (index === targetIndex) {
          return;
        }
        this.vm.currentTabIndex = targetIndex;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF5F5F5')
    .padding({
      top: BarVM.instance.staBarH,
      left: this.getPaddingH(),
      right: this.getPaddingH()
    })
  }
}

