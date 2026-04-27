//血糖历史页
import { BloodGlucoseHistoryItem } from '../types/BloodGlucoseTypes';
import { BloodGlucoseHistoryVM } from '../viewmodel/BloodGlucoseHistoryVM';
import { BloodGlucoseHistoryItemView } from '../components/BloodGlucoseHistoryItemView';
import { BaseHistoryRow, HistoryRowConfig } from '../components/BaseHistoryRow';

// 血糖历史记录项Builder
@Builder
function buildBloodGlucoseHistoryItem(item: object, _onItemClick: () => void) {
  BloodGlucoseHistoryItemView({ item: item as BloodGlucoseHistoryItem })
}

/**
 * @usage: 用于展示血糖历史记录的页面。包含自定义导航栏（返回按钮、标题）、月份选择器、血糖历史记录列表。
 * 主要数据结构包括BloodGlucoseHistoryVM（血糖历史视图模型）、BloodGlucoseHistoryItem（血糖历史记录项）。
 * 包含ForEach逻辑用于渲染历史记录列表和分割线。
 * @layout: 页面采用垂直布局（Column），顶部为自定义导航栏（Stack布局），下方为主要内容区域（Column布局），
 * 包含月份选择区域（水平布局，左对齐月份标题，右对齐下拉箭头）、历史记录列表（垂直布局，每项包含血糖值、状态用餐时间、日期时间）。
 * @constraints: 导航栏高度和样式不允许修改，历史记录项布局结构不允许修改，血糖状态颜色固定不可修改（偏低橙色、偏高红色、正常绿色），
 * 月份选择器样式不允许修改。
 * @isGen: true
 * @fileType: page
 * @zhName: 血糖历史记录页面
 * @subPage:
 * @component: BloodGlucoseHistoryItemView
 */
@ComponentV2
export struct BloodGlucoseHistoryPage {
  private vm: BloodGlucoseHistoryVM = BloodGlucoseHistoryVM.instance;

  build() {
    BaseHistoryRow({
      vm: this.vm,
      config: this.createConfig()
    })
  }

  private createConfig(): HistoryRowConfig {
    const config = new HistoryRowConfig();
    config.title = '历史记录';
    config.itemBuilder = wrapBuilder<[object, () => void]>(buildBloodGlucoseHistoryItem);
    config.hasDetailPage = false;
    return config;
  }
}




@Builder
export function BloodGlucoseHistoryPageBuilder() {
  BloodGlucoseHistoryPage()
}

