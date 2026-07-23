import * as wxopensdk from '@tencent/wechat_open_sdk';

export type WeChatRequestCb = (request: wxopensdk.BaseReq) => void;

export type WeChatResponseCb = (response: wxopensdk.BaseResp) => void;

export type PaymentCallback = (type: PaymentType, isSuccess: boolean) => void;

export enum PaymentType {
  WECHAT = 'wechat',
  ALIPAY = 'alipay',
  HUAWEI = 'huawei'
}

/**
 * 宽度断点，根据宽度值判断
 */
export enum WidthBreakpoint {
  XS = 'xs',
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl',
  XXL = 'xxl'
}

/**
 * 高度断点，根据高宽比判断
 */
export enum HeightBreakpoint {
  XS = 'xs', // [0, 0.5)
  SM = 'sm', // [0.5, 0.8)
  MD = 'md', // [0.8, 1.2)
  LG = 'lg'  // [1.2, Number.MAX_SAFE_INTEGER)
}
