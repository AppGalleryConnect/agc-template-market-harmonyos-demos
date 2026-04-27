export enum PickerType {
  SHEET = 0,
  DIALOG = 1,
  FULLSCREEN = 2
}

export enum ChannelType {
  HUAWEI_PAY = 0,
  ALI_PAY = 1,
  WECHAT_PAY = 2
}

export interface Channel {
  type: ChannelType,
  name: string,
  selectEvent: (event: ClickEvent) => void;
}

export class WxExtraInfo {
  partnerId: string = ''
  appId: string = ''
  packageValue: string = ''
  prepayId: string = ''
  nonceStr: string = ''
  timeStamp: string = ''
  sign: string = ''
  extData: string = ''
}

export const PAYMENT_CHANNEL: Channel[] =
  [{
    type: ChannelType.HUAWEI_PAY,
    name: '华为支付',
    selectEvent: () => {
    },
  },
    {
      type: ChannelType.ALI_PAY,
      name: '支付宝',
      selectEvent: () => {
      },
    },
    {
      type: ChannelType.WECHAT_PAY,
      name: '微信支付',
      selectEvent: () => {
      },
    }];