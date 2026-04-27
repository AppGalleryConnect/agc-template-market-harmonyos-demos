//心率历史页
import { HeartRateHistoryItem } from '../types/HeartRateTypes';
import { HeartRateHistoryVM } from '../viewmodel/HeartRateHistoryVM';
import { BaseHistoryRow, HistoryRowConfig } from '../components/BaseHistoryRow';
import { HeartRateHistoryItemView } from '../components/HeartRateHistoryItemView';

@Builder
export function HeartRateHistoryPageBuilder() {
  HeartRateHistoryPage()
}

// 心率历史记录项Builder
@Builder
function buildHeartRateHistoryItem(item: object, onItemClick: () => void) {
  HeartRateHistoryItemView({
    item: item as HeartRateHistoryItem,
    onItemClick: onItemClick
  })
}

/**
 * @usage: 用于展示心率历史记录的页面。包含自定义导航栏（返回按钮、标题）、月份选择器、心率历史记录列表（支持点击跳转到详情页）。
 * 主要数据结构包括HeartRateHistoryVM（心率历史视图模型）、HeartRateHistoryItem（心率历史记录项）。
 包含ForEach逻辑用于渲染历史记录列表和分割线。
 * @layout: 页面采用垂直布局（Column），顶部为自定义导航栏（Stack布局），下方为主要内容区域（Column布局），
 * 包含月份选择区域（水平布局，左对齐月份标题，右对齐下拉箭头）、历史记录列表（垂直布局，每项包含心率范围、日期时间、右箭头）。
 * @constraints: 导航栏高度和样式不允许修改，历史记录项布局结构不允许修改，月份选择器样式不允许修改，右箭头图标不允许修改。
 * @isGen: true
 * @fileType: page
 * @zhName: 心率历史记录页面
 * @subPage: HeartRateDetailPage
 * @component: HeartRateHistoryItemView
 */
@ComponentV2
export struct HeartRateHistoryPage {
  private vm: HeartRateHistoryVM = HeartRateHistoryVM.instance;
  private routerModule: NavPathStack | null = null;

  private handleRouterReady = (router: NavPathStack): void => {
    this.routerModule = router;
  }

  private handleItemClick = (item: object): void => {
    this.vm.setDetailData(item as HeartRateHistoryItem);
    if (this.routerModule) {
      this.routerModule.pushPathByName('HeartRateDetailPage', null);
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
    config.itemBuilder = wrapBuilder<[object, () => void]>(buildHeartRateHistoryItem);
    config.hasDetailPage = true;
    return config;
  }
}

