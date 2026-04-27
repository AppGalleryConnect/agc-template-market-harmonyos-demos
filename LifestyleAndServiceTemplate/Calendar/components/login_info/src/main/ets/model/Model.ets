@ObservedV2
export class VipInfo {
  @Trace isVip: boolean = false
  @Trace vipType: string = ''
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

  constructor(userInfo?: UserInfo | Record<string, string | Uint8Array >) {
    this.authCode = userInfo?.authCode as string || ''
    this.avatar = userInfo?.avatar as string || ''
    this.idToken = userInfo?.idToken as string || ''
    this.phoneNumber = userInfo?.phoneNumber as string || ''
    this.userName = userInfo?.userName || ''
    this.openID = userInfo?.openID as string || ''
  }
}

export class LoginParams {
  phoneNumber?:string = ''
  authorizationCode?:string = ''
}

// 用户数据
@ObservedV2
export class UserState {
  @Trace isLogin: boolean = false;
  @Trace userInfo: UserInfo = new UserInfo();

  constructor(isLogin?: boolean, userInfo?: UserInfo) {
    this.userInfo = new UserInfo(userInfo)
    this.isLogin = isLogin ?? false
  }
}

@ObservedV2
export class ThemeState {
  @Trace current: ResourceStr = '#c4272b';
  @Trace titleColor: ResourceStr = '#ffffff';
}
