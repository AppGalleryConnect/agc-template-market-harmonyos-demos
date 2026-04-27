import { PersistenceV2, Type } from '@kit.ArkUI';
import { Coupon } from '../types';

@ObservedV2
export class UserInfoModel {
  @Type(Coupon)
  @Trace couponList: Coupon[] = []
  @Trace isLogin: boolean = false
  @Trace id: number = 0;
  @Trace name: string = '';
  @Trace nickname: string = '';
  @Trace sex: string = '';
  @Trace cellphone: string = '';
  @Trace birthday: string = '';
  @Trace avatar: string = '';
  @Trace isVip: boolean = false;
  @Trace points: number = 0;
  @Trace realNameAuthFlag: number = 0
}

/**
 * 所有ViewModel的基类，支持UI动态观测
 */
@ObservedV2
export abstract class BaseViewModel {
  @Trace userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
}