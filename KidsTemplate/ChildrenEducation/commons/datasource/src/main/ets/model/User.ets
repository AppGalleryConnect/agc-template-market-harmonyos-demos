@ObservedV2
export class User {
  @Trace isLogin: boolean = false;
  @Trace userName: string = '点击登录';
  @Trace userAvatar: string = '';
  @Trace phone: string = '';
}