export interface TabListItem {
  label: string;
  icon: Resource;
  iconChecked: Resource;
  component: WrappedBuilder<[]>;
}

export interface UserInfoResp {
  id: number;
  name: string | null;
  nickname: string | null;
  sex: string | null;
  cellphone: string | null;
  birthday: string | null;
  userHeadImg: string | null;
}
