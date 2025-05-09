export interface UserInfo {
  id: number;
  avatar: string;
  name: string;
  nickname: string;
  sex: string;
  cellphone: string;
  birthday: string;
}

export interface MemberInfo {
  //会员卡号
  memberCardNo: string;

  //会员类别名称
  memberClassTName: string;

  //会员类别等级
  memberClassTLevel: string;

  //积分余额
  pointBalance: string;
}
