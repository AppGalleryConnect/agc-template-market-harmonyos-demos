@ObservedV2
export class UserModel {
  @Trace loginToken: string = ''
  @Trace isPhoneAssociated: boolean = false
  @Trace id: number = 0
  @Trace name: string = ''
  @Trace nickname: string = ''
  @Trace sex: string = ''
  @Trace cellphone: string = ''
  @Trace birthday: string = ''
  @Trace userHeadImg: ResourceStr = ''
}