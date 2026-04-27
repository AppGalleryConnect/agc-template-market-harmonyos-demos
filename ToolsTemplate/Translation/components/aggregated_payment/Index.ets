import * as wxopensdk from '@tencent/wechat_open_sdk';

export { AggregatedPaymentPicker } from './src/main/ets/components/AggregatedPaymentPicker';
export { PickerType, ChannelType, WxExtraInfo } from './src/main/ets/common/Constant'
export { ChannelInfo } from './src/main/ets/model/Index'

export { wxEventHandler} from './src/main/ets/model/WXApiWrap'

export const wxApi = wxopensdk.WXAPIFactory.createWXAPI('wx05b3e2e9fc730840')