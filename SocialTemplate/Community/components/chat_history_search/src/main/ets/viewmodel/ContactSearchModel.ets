@ObservedV2
export class ContactSearchModel {
  @Trace searchUserId: string = '';
  @Trace searchNickName: string = '';
  @Trace searchAvatarUrl: string = '';

  constructor(userId: string, nickName: string, avatarUrl: string) {
    this.searchUserId = userId;
    this.searchNickName = nickName;
    this.searchAvatarUrl = avatarUrl;
  }
}
