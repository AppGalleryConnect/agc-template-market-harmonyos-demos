import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { ContextUtils, GlobalContextUtils } from '../utils/ContextUtils';
import { UserInfoModel } from './UserInfoModel';
import { BreakpointModel } from './BreakpointModel';
import { WindowModel } from './WindowModel';

/**
 * 所有ViewModel的基类，支持UI动态观测
 */
@ObservedV2
export abstract class BaseViewModel {
  @Trace windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Trace userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace contextModel: ContextUtils = GlobalContextUtils;
}