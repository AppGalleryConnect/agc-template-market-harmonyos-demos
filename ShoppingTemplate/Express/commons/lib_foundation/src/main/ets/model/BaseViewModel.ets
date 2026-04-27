import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { BreakpointModel } from './BreakpointModel';
import { WindowInfo } from './WindowInfo';

@ObservedV2
export class UserInfoModel {
  @Trace isLogin: boolean = false
  @Trace id: number = 0;
  @Trace name: string = '';
  @Trace nickname: string = '';
  @Trace gender: number = 2;
  @Trace phone: string = '';
  @Trace birthday: string = '';
  @Trace avatar: string = '';
  // 是否开通会员
  @Trace isVip: boolean = false;
  // 会员超期时间
  @Trace vipExpireTime: number = 0;
  // 用户积分
  @Trace points: number = 0;
  // 是否实名认证
  @Trace isRealName: number = 0;
  // 是否领取会员权益
  @Trace isClaimBenefit: boolean = false;
}

/**
 * 所有ViewModel的基类，支持UI动态观测
 */
@ObservedV2
export abstract class BaseViewModel {
  @Trace windowModel: WindowInfo = AppStorageV2.connect(WindowInfo, () => new WindowInfo())!;
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
}