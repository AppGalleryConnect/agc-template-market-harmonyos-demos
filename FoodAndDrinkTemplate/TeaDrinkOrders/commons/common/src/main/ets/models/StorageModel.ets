import { OrderTypeEnum } from '../constants/Common';
import { getAnonymousTel } from '../utils/Utils';
import { MyCar, Reduction, StoreInfo, UserInfo } from './ResponseModel';
import { window } from '@kit.ArkUI';

// 应用信息
export class AppInfoModel {
  packageName: string = '';
}

// 店铺信息
@ObservedV2
export class StoreInfoModel {
  @Trace storeId: string = '';
  @Trace tel: string = '';
  @Trace orderType: number = OrderTypeEnum.PICK_SELF
  @Trace distance: number = 0
  @Trace storeInfo: StoreInfo = new StoreInfo()
}

// 购物车信息
@ObservedV2
export class MyCarModel {
  @Trace myCar: MyCar = new MyCar()
  @Trace carCheck: Array<string> = []
}

// 购物车信息
@ObservedV2
export class UserInfoModel {
  @Trace userInfo: UserInfo = new UserInfo()
  @Trace isRelative: boolean = false

  getUserName(): ResourceStr {
    return this.isRelative ? this.userInfo.name : $r('app.string.no_relate')
  }

  getTotalScore(): string {
    return this.isRelative ? this.userInfo.totalScore : '0'
  }

  getTel(): string {
    return getAnonymousTel(this.userInfo.userTel)
  }
}

// 购物车信息
@ObservedV2
export class ReductionModel {
  @Trace reduction: Reduction = new Reduction()
}

// 用户头像持久化
@ObservedV2
export class UserIconModel {
  @Trace isSaved: boolean = false
  @Trace userIconPath: string = 'userImage.jpg'
}

// 用户头像持久化
@ObservedV2
export class WindowModel {
  @Trace windowTopHeight: number = 38.77;
  @Trace windowBottomHeight: number = 28;
  @Trace windowStage?: window.WindowStage = undefined;

  getWindowTopHeight() {
    return this.windowTopHeight || 38.77;
  }

  getWindowBottomHeight() {
    return this.windowBottomHeight || 28;
  }
}

@ObservedV2
export class FormCard {
  @Trace id: number = 0
  url: string = ''
  @Trace orderId: string = ''
  @Trace isOrderJump: boolean = false
}