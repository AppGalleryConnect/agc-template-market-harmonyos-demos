/**
 * 服务卡片-数据模型
 */
export class FormCardData {
  data: string = '';
}

export class FormItemModel {
  goodId: string
  orderId: string
  title: string
  appointTime: string
  addressName: string
  isShow: boolean
  appointTimeRaw: number

  constructor(goodId: string, orderId: string, title: string, appointTime: string, addressName: string,
    isShow: boolean = true, appointTimeRaw: number = 0) {
    this.goodId = goodId;
    this.orderId = orderId;
    this.title = title;
    this.appointTime = appointTime;
    this.addressName = addressName;
    this.isShow = isShow;
    this.appointTimeRaw = appointTimeRaw;
  }
}

export interface MenuModel {
  label: string;
  image: ResourceStr;
  backgroundColor?: ResourceColor;
  mainParam?: IJumpCategoryParam;
}

export const MENU_DATTA: MenuModel[] = [
  {
    label: '日常清洁',
    image: $r('sys.symbol.clean_fill'),
    backgroundColor: $r('sys.color.multi_color_04'),
    mainParam: {
      tabIndex: 1,
      listInitialIndex: 1,
    },
  },
  {
    label: '家电维修',
    image: $r('sys.symbol.spanner'),
    backgroundColor: $r('sys.color.multi_color_02'),
    mainParam: {
      tabIndex: 1,
      listInitialIndex: 4,
    },
  },
  {
    label: '保姆月嫂',
    image: $r('sys.symbol.children'),
    backgroundColor: $r('sys.color.multi_color_06'),
    mainParam: {
      tabIndex: 1,
      listInitialIndex: 2,
    },
  },
  {
    label: '管道疏通',
    image: $r('sys.symbol.rush_pipe'),
    backgroundColor: $r('sys.color.multi_color_03'),
    mainParam: {
      tabIndex: 1,
      listInitialIndex: 3,
    },
  },
];

export interface IJumpCategoryParam {
  tabIndex: number;
  listInitialIndex: number;
}

export enum OrderStatus {
  ALL = '全部',
  TO_PAY = '待支付',
  TO_USE = '待使用',
  NORMAL_FINISH = '已完成',
  REFUND = '退款标识',
  REFUND_ING = '退款中',
  REFUND_DONE = '已退款',
  CANCEL = '已取消',
}