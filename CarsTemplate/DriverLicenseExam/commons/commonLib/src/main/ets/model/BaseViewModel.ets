import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from './BreakpointModel';
import { TabModel } from './TabModel';

/**
 * 所有ViewModel的基类，支持UI动态观测
 */
@ObservedV2
export abstract class BaseViewModel {
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace tabModel: TabModel = AppStorageV2.connect(TabModel, () => new TabModel())!;
}