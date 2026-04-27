import { BalanceChangeType, CustomKeyboardButtonType, CustomKeyboardDisplayType } from './Enums';
import { BalanceResourceItem, CustomKeyboardItem } from './Types';

export class HomeConstants {
  public static readonly RESOURCE_NO_FILTER = -1;
}

export class BillConstants {
  public static readonly FONT_SIZE_10 = '10fp';
  public static readonly FONT_SIZE_12 = '12fp';
  public static readonly FONT_SIZE_14 = '14fp';
  public static readonly FONT_SIZE_16 = '16fp';
  public static readonly FONT_SIZE_18 = '18fp';
  public static readonly FONT_SIZE_20 = '20fp';
  public static readonly FONT_SIZE_24 = '24fp';
  public static readonly THEME_COLOR = '#94B982';
  public static readonly THEME_COLOR_SECOND = '#F2992C';
  public static readonly FONT_COLOR_LEVEL1 = '#E6000000';
  public static readonly FONT_COLOR_1_INVERT = '#FFFFFF';
  public static readonly FONT_COLOR_LEVEL2 = '#99000000';
  public static readonly FONT_COLOR_LEVEL3 = '#66000000';
  public static readonly DIVIDER_COLOR = '#C4C4C4';
  public static readonly WARNING_COLOR = $r('sys.color.warning');
  public static readonly BACKGROUND_COLOR = '#FFFFFF';
  public static readonly BACKGROUND_COLOR_GREY = '#f1f3f5';
  public static readonly BACKGROUND_COLOR_GREY_2 = '#0D000000';
  public static readonly BORDER_RADIUS_4 = '4vp';
  public static readonly BORDER_RADIUS_16 = '16vp';
  public static readonly BORDER_RADIUS_CAPSULE = '99vp';
  public static readonly INCOME_RESOURCE_MAP: BalanceResourceItem[] = [
    {
      key: 201,
      name: '工资',
      icon: $r('app.media.ic_income_0'),
      uncheckedIcon: $r('app.media.ic_income_unchecked_0'),
      type: BalanceChangeType.INCOME,
      sortNum: 1,
    },
    {
      key: 202,
      name: '兼职',
      icon: $r('app.media.ic_income_1'),
      uncheckedIcon: $r('app.media.ic_income_unchecked_1'),
      type: BalanceChangeType.INCOME,
      sortNum: 2,
    },
    {
      key: 203,
      name: '退款',
      icon: $r('app.media.ic_income_2'),
      uncheckedIcon: $r('app.media.ic_income_unchecked_2'),
      type: BalanceChangeType.INCOME,
      sortNum: 3,
    },
    {
      key: 204,
      name: '其他',
      icon: $r('app.media.ic_income_others'),
      uncheckedIcon: $r('app.media.ic_income_unchecked_others'),
      type: BalanceChangeType.INCOME,
      sortNum: 4,
    },
  ];
  public static readonly EXPENSE_RESOURCE_MAP: BalanceResourceItem[] = [
    {
      key: 101,
      name: '餐饮',
      icon: $r('app.media.ic_expense_0'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_0'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 1,
    },
    {
      key: 102,
      name: '交通',
      icon: $r('app.media.ic_expense_1'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_1'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 2,
    },
    {
      key: 103,
      name: '服饰',
      icon: $r('app.media.ic_expense_2'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_2'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 3,
    },
    {
      key: 104,
      name: '购物',
      icon: $r('app.media.ic_expense_3'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_3'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 4,
    },
    {
      key: 105,
      name: '服务',
      icon: $r('app.media.ic_expense_4'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_4'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 5,
    },
    {
      key: 106,
      name: '教育',
      icon: $r('app.media.ic_expense_5'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_5'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 6,
    },
    {
      key: 107,
      name: '娱乐',
      icon: $r('app.media.ic_expense_6'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_6'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 7,
    },
    {
      key: 108,
      name: '运动',
      icon: $r('app.media.ic_expense_7'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_7'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 8,
    },
    {
      key: 109,
      name: '生活缴费',
      icon: $r('app.media.ic_expense_8'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_8'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 9,
    },
    {
      key: 110,
      name: '旅行',
      icon: $r('app.media.ic_expense_9'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_9'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 10,
    },
    {
      key: 111,
      name: '宠物',
      icon: $r('app.media.ic_expense_10'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_10'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 11,
    },
    {
      key: 112,
      name: '医疗',
      icon: $r('app.media.ic_expense_11'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_11'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 12,
    },
    {
      key: 113,
      name: '保险',
      icon: $r('app.media.ic_expense_12'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_12'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 13,
    },
    {
      key: 114,
      name: '公益',
      icon: $r('app.media.ic_expense_13'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_13'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 14,
    },
    {
      key: 115,
      name: '亲子',
      icon: $r('app.media.ic_expense_14'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_14'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 15,
    },
    {
      key: 116,
      name: '酒店',
      icon: $r('app.media.ic_expense_15'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_15'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 16,
    },
    {
      key: 117,
      name: '美容',
      icon: $r('app.media.ic_expense_16'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_16'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 17,
    },
    {
      key: 118,
      name: '人情',
      icon: $r('app.media.ic_expense_17'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_17'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 18,
    },
    {
      key: 119,
      name: '其他',
      icon: $r('app.media.ic_expense_others'),
      uncheckedIcon: $r('app.media.ic_expense_unchecked_others'),
      type: BalanceChangeType.EXPENSE,
      sortNum: 19,
    },
  ];
  public static readonly CUSTOM_KEYBOARD_LIST: CustomKeyboardItem[] = [
    {
      display: CustomKeyboardDisplayType.TEXT,
      type: CustomKeyboardButtonType.NUMBER,
      text: '1',
    },
    {
      display: CustomKeyboardDisplayType.TEXT,
      type: CustomKeyboardButtonType.NUMBER,
      text: '2',
    },
    {
      display: CustomKeyboardDisplayType.TEXT,
      type: CustomKeyboardButtonType.NUMBER,
      text: '3',
    },
    {
      display: CustomKeyboardDisplayType.TEXT_WITH_IMAGE,
      type: CustomKeyboardButtonType.CALENDAR,
      icon: $r('app.media.ic_calendar'),
      text: '今天',
    },
    {
      display: CustomKeyboardDisplayType.TEXT,
      type: CustomKeyboardButtonType.NUMBER,
      text: '4',
    },
    {
      display: CustomKeyboardDisplayType.TEXT,
      type: CustomKeyboardButtonType.NUMBER,
      text: '5',
    },
    {
      display: CustomKeyboardDisplayType.TEXT,
      type: CustomKeyboardButtonType.NUMBER,
      text: '6',
    },
    {
      display: CustomKeyboardDisplayType.TEXT,
      type: CustomKeyboardButtonType.SUBTRACTION,
      text: '-',
    },
    {
      display: CustomKeyboardDisplayType.TEXT,
      type: CustomKeyboardButtonType.NUMBER,
      text: '7',
    },
    {
      display: CustomKeyboardDisplayType.TEXT,
      type: CustomKeyboardButtonType.NUMBER,
      text: '8',
    },
    {
      display: CustomKeyboardDisplayType.TEXT,
      type: CustomKeyboardButtonType.NUMBER,
      text: '9',
    },
    {
      display: CustomKeyboardDisplayType.TEXT,
      type: CustomKeyboardButtonType.ADDITION,
      text: '+',
    },
    {
      display: CustomKeyboardDisplayType.TEXT,
      type: CustomKeyboardButtonType.POINT,
      text: '.',
    },
    {
      display: CustomKeyboardDisplayType.TEXT,
      type: CustomKeyboardButtonType.NUMBER,
      text: '0',
    },
    {
      display: CustomKeyboardDisplayType.IMAGE,
      type: CustomKeyboardButtonType.DELETE,
      text: '',
      icon: $r('app.media.ic_keyboard_delete'),
    },
    {
      display: CustomKeyboardDisplayType.TEXT,
      type: CustomKeyboardButtonType.CONFIRM,
      text: '完成',
      bgColor: BillConstants.THEME_COLOR,
      fontColor: BillConstants.FONT_COLOR_1_INVERT,
    },
  ];
  public static readonly EXPENSE_COLOR_LIST: number[] = [
    0x4b6f3f, 0x638750, 0x7ea568, 0x94b982, 0xabd39c, 0xc6e5b9, 0xdff3d7,
    0xf2fdee,
  ];
  public static readonly INCOME_COLOR_LIST: number[] = [
    0xb3511e, 0xd77525, 0xf2992c, 0xfbb935, 0xffce52, 0xffe38e, 0xfff1ca,
    0xfffbef,
  ];
  // argb
  public static readonly EXPENSE_BAR_INIT_COLOR: number = 0x8094b982;
  // argb
  public static readonly INCOME_BAR_INIT_COLOR: number = 0x80f2992c;
  // rgb
  public static readonly EXPENSE_BAR_HIGHLIGHT_COLOR: number = 0x94b982;
  // rgb
  public static readonly INCOME_BAR_HIGHLIGHT_COLOR: number = 0xf2992c;
}