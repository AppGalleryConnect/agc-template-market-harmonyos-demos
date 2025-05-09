import { RouterMap } from 'commonlib';


export interface SettingItem {
  icon?: ResourceStr;
  label: string;
  url: string;
  group: number;
  type: RouterMap;
}


// 精彩推荐
export interface RecommendListItem{
  id:string,
  img:string,
  name:string,
  detail:string,
  price:number
}

// 常用联系人 (获取，修改，新增)
export interface Contacts{
  personID:string,
  cardType:string,
  name:string,
  phone:string,
  cardID:string
}



export enum Gender {
  MALE = '1',
  FEMALE = '2',
}
