@ObservedV2
export class UserInfo {
  @Trace userId: number = 0;
  @Trace nickName?: string = ''
  @Trace avatar?: string = ''
  @Trace mobile?: string = ''
  @Trace name?: string;
  @Trace gender?: number;
  @Trace birth?: number;
  idToken?: string = '';
  authCode?: string = '';
}

export enum CancelAuthState {
  SUCCESS = 1,
  ERROR = 2
}