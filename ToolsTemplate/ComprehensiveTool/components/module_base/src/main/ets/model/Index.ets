@ObservedV2
export class UsedCount {
  @Trace count: number = 0;
}

@ObservedV2
export class MemberStatus {
  @Trace isMember: boolean = false;
  @Trace memberType?: number = 0;
  @Trace expireTime?: string = '';
}

/**
 * 用户信息
 */
@ObservedV2
export class UserInfoModel {
  @Trace isLogin: boolean = false;
  @Trace userId: string = '';
  @Trace userIcon: string = '';
  @Trace userNickName: string = '';
  @Trace loginChannel: string = '';
  @Trace userPhone: string = '';
}

export const MAX_FREE_USE_TIME = 0