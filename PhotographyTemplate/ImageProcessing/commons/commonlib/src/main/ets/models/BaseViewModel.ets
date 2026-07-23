import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { WindowSize } from './WindowSize';
import { BreakpointModel } from './BreakpointModel';
import { UserInfo } from './UserInfo';

/**
 * 所有ViewModel的基类，支持UI动态观测
 */
@ObservedV2
export abstract class BaseViewModel {
  @Trace windowSize: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!;
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
}