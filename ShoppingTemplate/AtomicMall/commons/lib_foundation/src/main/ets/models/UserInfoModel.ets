@ObservedV2
export class UserInfoModel {
  @Trace
  public nickname: string = '';
  @Trace
  public phone: string = '';
  @Trace
  public avatar: ResourceStr = '';
  @Trace
  public anonymousPhone: string = '';
  @Trace
  public openId?: string;
  @Trace
  public authCode?: string;
  @Trace
  public isMember: boolean = false;

  public reset(): void {
    this.nickname = '';
    this.phone = '';
    this.avatar = '';
    this.anonymousPhone = '';
  }
}
