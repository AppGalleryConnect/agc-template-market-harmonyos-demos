import { BaseSelectedListItem } from 'common'

@ObservedV2
export class NavItem {
  label: ResourceStr = ''
  type: ResourceStr = ''
  icon: ResourceStr = ''

  constructor(label: ResourceStr, type: ResourceStr, icon: ResourceStr) {
    this.label = label
    this.type = type
    this.icon = icon
  }
}

export enum SpaceType {
  'ECONOMY_CLASS' = '经济舱',
  'FIRST_CLASS' = '公务舱/头等舱',
}

export class PayTypeData {
  icon: ResourceStr = ''
  label: ResourceStr = ''
  type: string = ''

  constructor(type: string, label: ResourceStr, icon: ResourceStr) {
    this.type = type
    this.label = label
    this.icon = icon
  }
}

export class MinePageModel {
  // 获取证件类型
  static getCardTypeList(): BaseSelectedListItem[] {
    return [
      new BaseSelectedListItem('idCard', '身份证'),
      new BaseSelectedListItem('Hukou', '户口簿'),
      new BaseSelectedListItem('passport', '护照'),
      new BaseSelectedListItem('taiwan', '台胞证'),
      new BaseSelectedListItem('hkMacau', '港澳台居民居住证')
    ]
  }
  // 获取支付方式
  static getPayTypeList(): PayTypeData[] {
    return [
      new PayTypeData('hwPay', '华为支付', $r('app.media.ic_hw_pay')),
      // new PayTypeData('aliPay', '支付宝', $r('app.media.ic_zhifubao_pay')),
    ]
  }

  // 获取订单功能数据
  static getOrderList(): NavItem[] {
    return [
      new NavItem('待支付', '1', $r('app.media.ic_waiting_for_payment')),
      new NavItem('待出行', '2', $r('app.media.ic_waiting_travel')),
      new NavItem('全部', '', $r('app.media.ic_all'))
    ]
  }

  // 获取功能菜单数据
  static getFunctionalList(): NavItem[] {
    return [
      new NavItem('常用乘机人', 'passenger', $r('app.media.ic_passenger')),
      new NavItem('客服中心', 'custom', $r('app.media.ic_custom')),
      new NavItem('设置', 'setting', $r('app.media.ic_setting')),
    ]
  }
}