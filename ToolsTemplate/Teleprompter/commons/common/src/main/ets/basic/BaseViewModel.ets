import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { UserInfo } from '../model/UserInfo';
import { BreakpointModel } from '../model/BreakpointModel';

/**
 * 所有ViewModel的基类，支持UI动态观测
 */
@ObservedV2
export abstract class BaseViewModel {
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  // 栅格断点监听
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
}