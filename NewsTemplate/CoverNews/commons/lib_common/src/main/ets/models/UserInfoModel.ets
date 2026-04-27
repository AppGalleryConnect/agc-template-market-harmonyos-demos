/**
 * 用户信息
 */
@ObservedV2
export class UserInfoModel {
  @Trace isLink: boolean = false;
  @Trace authorId: string = '';
  @Trace authorNickName: string = '';
  @Trace authorIcon: ResourceStr = $r('app.media.avatar_grey');
  @Trace authorPhone: string = '';
  @Trace authorIp: string = '';
}