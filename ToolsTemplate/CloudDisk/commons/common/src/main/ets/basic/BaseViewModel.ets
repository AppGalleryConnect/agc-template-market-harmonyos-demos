/**
 * @fileType: common
 * @zhName: 基础视图模型类
 */
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { UserInfo } from '../model/UserInfo';
import { DisplayModel } from '../model/DisplayModel';
import { BreakpointModel } from '../model/BreakpointModel';

/**
 * 所有ViewModel的基类，支持UI动态观测
 */
@ObservedV2
export abstract class BaseViewModel {
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  // 横屏与折叠屏检查
  @Trace displayModel: DisplayModel = AppStorageV2.connect(DisplayModel, () => new DisplayModel())!;
  // 栅格断点监听
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
}