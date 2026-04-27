import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { TabModel } from './TabModel';
import { WindowModel } from './WindowModel';
import { WindowStageModel } from './WindowStageModel';
import { BreakpointModel } from './BreakpointModel';
import { UserInfoModel } from './UserInfoModel';
import { NetworkModel } from './NetworkModel';
import { ContextUtils, GlobalContextUtils } from '../utils/ContextUtils';
import { DisplayModel } from './DisplayModel';

/**
 * 所有ViewModel的基类，支持UI动态观测
 */
@ObservedV2
export abstract class BaseViewModel {
  @Trace windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Trace userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Trace tabModel: TabModel = AppStorageV2.connect(TabModel, () => new TabModel())!;
  @Trace windowStageModel: WindowStageModel = AppStorageV2.connect(WindowStageModel, () => new WindowStageModel())!;
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace networkModel: NetworkModel = AppStorageV2.connect(NetworkModel, () => NetworkModel.getInstance())!;
  @Trace contextModel: ContextUtils = GlobalContextUtils;
  @Trace displayModel: DisplayModel = AppStorageV2.connect(DisplayModel, () => new DisplayModel())!;
}