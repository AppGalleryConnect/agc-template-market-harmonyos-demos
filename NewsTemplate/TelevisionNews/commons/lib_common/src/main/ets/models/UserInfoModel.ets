/**
 * 用户信息
 */
@ObservedV2
export class UserInfoModel {
  @Trace isRelative: boolean = false;
  @Trace authorId: string = '';
  @Trace authorNickName: string = '';
  @Trace authorIcon: string = '';
  @Trace authorDesc: string = '';
  @Trace authorPhone: string = '';
  @Trace authCode: string = '';
  @Trace userIconPath: string = '';
  @Trace isSaved: boolean = false
  @Trace authorIp: string = '';
  @Trace watchersCount: number = 0;
  @Trace followersCount: number = 0;
  @Trace subscribe: string[] = [];
}