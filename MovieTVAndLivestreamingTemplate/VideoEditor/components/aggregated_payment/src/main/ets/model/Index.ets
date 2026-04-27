import { ChannelType, WxExtraInfo } from '../common/Constant';

export class ChannelInfo {
  channelType: ChannelType = ChannelType.HUAWEI_PAY
  name: string = '';
  appId?: string = '';
  icon: ResourceStr = '';
  preOrderInfo: string | WxExtraInfo = '';
  event?: ()=> void = ()=> {}
}
