@ObservedV2
export class UserInfo {
  @Trace id: number = 0;
  @Trace avatar: ResourceStr = '';
  @Trace phone: string = '';
  @Trace nickname: string = '';
  @Trace name: string = '';
  // 性别
  @Trace gender: number = 2;
  @Trace personalIntroduction: string = '';
  @Trace isMale: boolean = false;
  @Trace isLogin: boolean = false;
  @Trace birthday: string = '';
  // 是否开通会员
  @Trace isVip: boolean = false;
  // 会员超期时间
  @Trace vipExpireTime: number = 0;
}
