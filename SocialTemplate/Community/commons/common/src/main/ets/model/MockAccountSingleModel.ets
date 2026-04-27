@ObservedV2
export class MockAccountSingleModel {
  @Trace userId: string = '';
  @Trace nickName: string = ''; // 昵称
  @Trace phone: string = ''; // 手机号
  @Trace avatarUrl: string = ''; // 头像
  @Trace userSig: string = '';
  @Trace selfSignature: string = '';//个人签名
}