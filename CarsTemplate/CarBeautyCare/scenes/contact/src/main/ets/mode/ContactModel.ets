// 店铺信息属性
export class ContactModel {
  name: string; //姓名
  contactNumber: string; //手机号
  choosen:boolean; //是否为默认联系人

  constructor(name: string, contactNumber: string,choosen:boolean) {
    this.name = name;
    this.contactNumber = contactNumber;
    this.choosen=choosen
  }
}

export const CONTACT_DEFAULT: ContactModel[] = [
  new ContactModel(
    '张三',
    '18000000000',
    true
  ),
  new ContactModel(
    '李四',

    '13911111111',
    false
  ),
];




