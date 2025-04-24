import { MinePageSetting, SettingType } from '../types';

export const MINE_PAGE_SETTING: MinePageSetting = {
  hotelName: '千和大酒店',
  settingList: [
    {
      icon: $r('app.media.ic_my_order'),
      label: '我的订单',
      url: '',
      group: 1,
      type: SettingType.MY_ORDERS,
    },
    {
      icon: $r('app.media.ic_security'),
      label: '隐私政策',
      url: '',
      group: 2,
      type: SettingType.INFO,
    },
    {
      icon: $r('app.media.ic_setting'),
      label: '账号设置',
      url: '',
      group:3,
      type: SettingType.ACCOUNT,
    },
  ],
};

export enum EditDialogType {
  NAME,
  NICKNAME,
  PHONE,
}

export enum Gender {
  MALE = '1',
  FEMALE = '2',
}
