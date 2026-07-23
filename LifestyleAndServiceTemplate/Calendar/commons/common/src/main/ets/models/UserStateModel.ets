export class ReservationRecord {
  recordName: string = ''
  calendarStartTime: number = 0
  calendarEndTime: number = 0
  eventId: number = -1
}

@ObservedV2
export class UserInfo {
  authCode?: string = ''
  @Trace avatar: string = ''
  idToken?: string = ''
  openID?: string = ''
  @Trace vipInfo: VipInfo = new VipInfo()
  @Trace phoneNumber: string = ''
  @Trace userName: string | Uint8Array = ''

  constructor(userInfo?: UserInfo | Record<string, string | Uint8Array>) {
    this.authCode = userInfo?.authCode as string || ''
    this.avatar = userInfo?.avatar as string || ''
    this.idToken = userInfo?.idToken as string || ''
    this.phoneNumber = userInfo?.phoneNumber as string || ''
    this.userName = userInfo?.userName || ''
    this.openID = userInfo?.openID as string || ''
  }
}

@ObservedV2
export class VipInfo {
  @Trace isVip: boolean = false
  @Trace vipType: string = ''
}

// 用户数据
@ObservedV2
export class UserState {
  @Trace isLogin: boolean = false;
  @Trace userInfo: UserInfo = new UserInfo();
  @Trace isAgreedPrivacy: boolean = false

  constructor(isLogin?: boolean, userInfo?: UserInfo) {
    this.userInfo = new UserInfo(userInfo)
    this.isLogin = isLogin ?? false
  }
}

// 设置数据
@ObservedV2
export class SettingState {
  // 更新通知
  @Trace updateSwitch: boolean = true
}