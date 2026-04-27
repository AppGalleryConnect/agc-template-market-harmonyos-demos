import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from './BreakpointModel';
import { TabBarType } from './TabBarModel';

/**
 * 应用的Tab信息
 */
@ObservedV2
export class TabModel {
  // 断点模型
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // 当前选择的tab下标
  @Trace selectedIndex: number = TabBarType.HOMEPAGE;
}

