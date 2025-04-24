export interface SettingItem {
  icon?: ResourceStr;
  label: string;
  url: string;
  group: number;
  type: SettingType;
}

export interface MinePageSetting {
  settingList: SettingItem[];
  hotelName: string;
}

export enum SettingType {
  MY_ORDERS,
  INFO,
  ACCOUNT,
  PENDING,
}
