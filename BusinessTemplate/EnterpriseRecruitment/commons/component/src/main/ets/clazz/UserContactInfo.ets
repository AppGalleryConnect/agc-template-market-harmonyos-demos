@ObservedV2
export class UserContactInfo {
  constructor(realName: string, phoneNumber: string, email: string) {
    this.realName = realName;
    this.phoneNumber = phoneNumber;
    this.email = email;
  }
  @Trace public realName: string = '';
  @Trace public phoneNumber: string = '';
  @Trace public email: string = '';
}