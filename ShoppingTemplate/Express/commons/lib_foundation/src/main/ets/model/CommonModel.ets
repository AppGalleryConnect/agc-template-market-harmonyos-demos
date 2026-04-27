export interface ISetting {
  text: string,
  value: number,
}

export interface IBuilderType {
  label: string,
  placeholder: string,
  placeholderColor: ResourceStr,
  text: string,
  textColor: ResourceStr,
  isDivider: boolean,
  isTime: boolean,
  isIcon: boolean,
  func: Function,
}

// 服务卡片
export class WidgetCardModel {
  // 卡片类型 2：2*2  3：2*4
  formDimension: number = 0;
  // 是否登录
  isLogin: boolean = false;
  // 订单号
  orderNo: string = '';
  // 始发地
  senderCity: string = '';
  // 目的地
  receiverCity: string = '';
  // 当前进度
  logistics: string = '';

  constructor(formDimension?: number) {
    if (formDimension) {
      this.formDimension = formDimension
    }
  }
}

export interface CardInfo {
  formId: string
  formDimension: number
}