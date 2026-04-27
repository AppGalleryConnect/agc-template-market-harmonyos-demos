@ObservedV2
export class UserInfo {
  @Trace id: string = '';
  @Trace nickName: string = ''; // 昵称
  @Trace avatarUrl: ResourceStr = ''; // 头像
  @Trace gender: string = ''; // 性别
  @Trace age: string = ''; // 年龄
  @Trace birthday: string = ''; // 出生日期
  @Trace telephone: string = ''; // 手机号
  @Trace email: string = ''; // 邮箱
  @Trace introDesc: string = ''; // 个人简介
  @Trace isLogin: boolean = false; // 是否登录
  @Trace isAuthentication:string = '0'
}

export class PopInfoResult {
  phone: string = ''
  uid: string = ''
}