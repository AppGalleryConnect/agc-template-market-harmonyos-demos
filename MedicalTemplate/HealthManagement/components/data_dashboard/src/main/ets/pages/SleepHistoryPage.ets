//睡眠历史页
import { SleepHistoryItem } from '../types/SleepTypes';
import { SleepHistoryVM } from '../viewmodel/SleepHistoryVM';
import { BaseHistoryRow, HistoryRowConfig } from '../components/BaseHistoryRow';
import { SleepHistoryItemView } from '../components/SleepHistoryItemView';

@Builder
export function SleepHistoryPageBuilder() {
  SleepHistoryPage()
}

// 睡眠历史记录项Builder
@Builder
function buildSleepHistoryItem(item: object, onItemClick: () => void) {
  SleepHistoryItemView({
    item: item as SleepHistoryItem,
    onItemClick: onItemClick
  })
}

/**
 * @usage: 用于展示睡眠历史记录的页面。包含自定义导航栏（返回按钮、标题）、月份选择器、睡眠历史记录列表（支持点击跳转到详情页）。
 * 主要数据结构包括SleepHistoryVM（睡眠历史视图模型）、SleepHistoryItem（睡眠历史记录项）。
 * 包含ForEach逻辑用于渲染历史记录列表和分割线。
 * @layout: 页面采用垂直布局（Column），顶部为自定义导航栏（Stack布局），下方为主要内容区域（Column布局），
 * 包含月份选择区域（水平布局，左对齐月份标题，右对齐下拉箭头）、历史记录列表（垂直布局，每项包含睡眠时长、日期时间、右箭头）。
 * @constraints: 导航栏高度和样式不允许修改，历史记录项布局结构不允许修改，月份选择器样式不允许修改，右箭头图标不允许修改。
 * @isGen: true
 * @fileType: page
 * @zhName: 睡眠历史记录页面
 * @subPage: SleepDetailPage
 * @component: SleepHistoryItemView
 */
@ComponentV2
export struct SleepHistoryPage {
  private vm: SleepHistoryVM = SleepHistoryVM.instance;
  private routerModule: NavPathStack | null = null;

  private handleRouterReady = (router: NavPathStack): void => {
    this.routerModule = router;
  }

  private handleItemClick = (item: object): void => {
    this.vm.setDetailData(item as SleepHistoryItem);
    if (this.routerModule) {
      this.routerModule.pushPathByName('SleepDetailPage', null);
    }
  }

  build() {
    BaseHistoryRow({
      vm: this.vm,
      config: this.createConfig(),
      onItemClick: this.handleItemClick,
      onRouterReady: this.handleRouterReady
    })
  }

  private createConfig(): HistoryRowConfig {
    const config = new HistoryRowConfig();
    config.title = '历史记录';
    config.itemBuilder = wrapBuilder<[object, () => void]>(buildSleepHistoryItem);
    config.hasDetailPage = true;
    return config;
  }
}

