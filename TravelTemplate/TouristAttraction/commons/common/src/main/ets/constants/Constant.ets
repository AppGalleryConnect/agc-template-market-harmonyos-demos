export class Constant {
  static readonly FULL_PERCENT: string = '100%';
  static readonly MAX_WIDTH: number = 448;
  static readonly BASE_URL: string = '';
  static readonly MAX_PURCHASE_QUANTITY: number = 5;
  static readonly MIN_PURCHASE_QUANTITY: number = 1;
  static readonly FIRST: number = 1;
  static readonly LAST_MONTH: number = 12;
  static readonly TOILET: string = '卫生间';
  static readonly PARKING: string = '停车场';
  static readonly MAX_TO_PAY_TIME: number = 900000;
  static readonly ORDER_SELECT = ['门票订单', '购物订单'];
  static readonly RICH_TEXT_URI = 'resource://rawfile/richtext.html';
  static readonly CLOUD_STORAGE_URL =
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/scenic-i0v1l/';
  // 用户授权成功
  static readonly USER_GRANT_SUCCESS = 0;
  static readonly LEFT_TAB_BAR_WIDTH: number = 96;
  static readonly LEFT_TAB_BAR_ITEM_HEIGHT: number = 100;
  static readonly BOTTOM_TAB_BAR_HEIGHT: number = 48;
}

export const CARD_TYPE_OPTIONS = [
  '身份证',
  '回乡证',
  '港澳台居住证',
  '台胞证',
  '护照',
];