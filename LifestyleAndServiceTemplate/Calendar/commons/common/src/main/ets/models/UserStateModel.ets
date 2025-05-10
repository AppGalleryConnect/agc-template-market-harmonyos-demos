import { Type } from '@kit.ArkUI'

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
  @Trace phoneNumber: string = ''
  @Trace userName: string = ''

  constructor(userInfo?: UserInfo | Record<string,string>) {
    this.authCode = userInfo?.authCode || ''
    this.avatar = userInfo?.avatar || ''
    this.idToken = userInfo?.idToken || ''
    this.phoneNumber = userInfo?.phoneNumber || ''
    this.userName = userInfo?.userName || ''
    this.openID = userInfo?.openID || ''
  }
}

// 用户数据
@ObservedV2
export class UserState {
  @Trace isLogin: boolean = false;
  @Trace userInfo: UserInfo = new UserInfo();
  @Type(ReservationRecord)
  @Trace recordList: ReservationRecord[] = []
}