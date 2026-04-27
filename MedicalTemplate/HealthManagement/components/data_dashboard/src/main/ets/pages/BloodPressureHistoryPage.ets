//血压历史页
import { BloodPressureHistoryItem } from '../types/BloodPressureTypes';
import { BloodPressureHistoryVM } from '../viewmodel/BloodPressureHistoryVM';
import { BaseHistoryRow, HistoryRowConfig } from '../components/BaseHistoryRow';
import { BloodPressureHistoryItemView } from '../components/BloodPressureHistoryItemView';

// 血压历史记录项Builder
@Builder
function buildBloodPressureHistoryItem(item: object, _onItemClick: () => void) {
  BloodPressureHistoryItemView({ item: item as BloodPressureHistoryItem })
}

/**
 * @usage: 用于展示血压历史记录的页面。包含自定义导航栏（返回按钮、标题）、月份选择器、血压历史记录列表。
 * 主要数据结构包括BloodPressureHistoryVM（血压历史视图模型）、BloodPressureHistoryItem（血压历史记录项）。
 * 包含ForEach逻辑用于渲染历史记录列表和分割线。
 * @layout: 页面采用垂直布局（Column），顶部为自定义导航栏（Stack布局），下方为主要内容区域（Column布局），
 * 包含月份选择区域（水平布局，左对齐月份标题，右对齐下拉箭头）、历史记录列表（垂直布局，每项包含血压值、血压状态、日期时间）。
 * @constraints: 导航栏高度和样式不允许修改，历史记录项布局结构不允许修改，血压状态颜色固定不可修改（正常高值橙色、正常绿色），
 * 月份选择器样式不允许修改。
 * @isGen: true
 * @fileType: page
 * @zhName: 血压历史记录页面
 * @subPage:
 * @component: BloodPressureHistoryItemView
 */
@ComponentV2
export struct BloodPressureHistoryPage {
  private vm: BloodPressureHistoryVM = BloodPressureHistoryVM.instance;

  build() {
    BaseHistoryRow({
      vm: this.vm,
      config: this.createConfig()
    })
  }

  private createConfig(): HistoryRowConfig {
    const config = new HistoryRowConfig();
    config.title = '历史记录';
    config.itemBuilder = wrapBuilder<[object, () => void]>(buildBloodPressureHistoryItem);
    config.hasDetailPage = false;
    return config;
  }
}



@Builder
export function BloodPressureHistoryPageBuilder() {
  BloodPressureHistoryPage()
}

