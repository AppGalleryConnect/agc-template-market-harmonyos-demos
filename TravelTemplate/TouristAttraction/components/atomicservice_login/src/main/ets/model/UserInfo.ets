@ObservedV2
export class UserInfo {
  authCode?: string = ''
  @Trace avatar?: ResourceStr = ''
  idToken?: string = ''
  @Trace phone?: string = ''
  @Trace nickname?: string = ''
  @Trace gender: number = 2
  @Trace birthday: string = ''
  @Trace isLink: boolean = false
}

export enum CancelAuthState {
  SUCCESS = 1,
  ERROR = 2
}