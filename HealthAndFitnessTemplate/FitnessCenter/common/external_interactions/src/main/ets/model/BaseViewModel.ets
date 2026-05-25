import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { TabModel } from './TabModel';
import { BreakpointModel } from './BreakpointModel';

/**
 * 所有ViewModel的基类，支持UI动态观测
 */
@ObservedV2
export abstract class BaseViewModel {
  @Trace tabModel: TabModel = AppStorageV2.connect(TabModel, () => new TabModel())!;
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
}