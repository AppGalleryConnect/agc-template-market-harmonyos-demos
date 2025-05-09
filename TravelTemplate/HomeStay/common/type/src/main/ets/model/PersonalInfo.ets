export class PersonalInfo {
  id: number;
  openId: string;
  nickName: string;
  gender: number;
  birthday: string;
  phone: string;
  avatar: ResourceStr;
  appId: string;

  constructor(
    id: number = 0,
    openId: string = '',
    nickName: string = '',
    gender: number = 0,
    birthday: string = '',
    phone: string = '',
    avatar: ResourceStr = '',
    appId: string = '',
  ) {
    this.id = id;
    this.openId = openId;
    this.nickName = nickName;
    this.gender = gender;
    this.birthday = birthday;
    this.phone = phone;
    this.avatar = avatar;
    this.appId = appId;
  }
}