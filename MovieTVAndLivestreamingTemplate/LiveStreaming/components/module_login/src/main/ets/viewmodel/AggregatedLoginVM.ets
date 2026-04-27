import * as wxopensdk from '@tencent/wechat_open_sdk';
import { common } from '@kit.AbilityKit';
import { LoginType } from '../common/Constant';
import { Channel, ExtraInfo } from '../model/Index';
import { Context } from '@ohos.arkui.UIContext';

@ObservedV2
export class AggregatedLoginVM {
  private static _instance: AggregatedLoginVM;
  private eventMap: Map<LoginType, ESObject> =
    new Map<LoginType, ESObject>([[LoginType.WECHAT, this.wxLogin]]);

  public static get instance() {
    if (!AggregatedLoginVM._instance) {
      AggregatedLoginVM._instance = new AggregatedLoginVM();
    }
    return AggregatedLoginVM._instance;
  }

  createEvent(channels: Channel[]): Channel[] {
    return channels.map((item: Channel) => {
      item.click = this.eventMap.get(item.type);
      return item;
    });
  }

  async wxLogin(extraInfo: ExtraInfo, context: common.UIAbilityContext) {
    let wxApi = wxopensdk.WXAPIFactory.createWXAPI(extraInfo.appId)
    let req = new wxopensdk.SendAuthReq;
    req.isOption1 = false;
    req.nonAutomatic = true;
    req.scope = extraInfo.scope;
    req.state = extraInfo.state;
    req.transaction = extraInfo.transaction;

    let finished = await wxApi.sendReq(context, req);
  }
}