import * as wxopensdk from '@tencent/wechat_open_sdk';

import { HashMap, util } from '@kit.ArkTS';

import { WeChatRequestCb, WeChatResponseCb } from '../common/CustomTypes';

class WechatEventHandler implements wxopensdk.WXApiEventHandler {

  private requestCallbacks: HashMap<string, WeChatRequestCb> = new HashMap();

  private responseCallbacks: HashMap<string, WeChatResponseCb> = new HashMap();

  public registerRequestEvent(cb: WeChatRequestCb): string {
    const id: string = util.generateRandomUUID(false);
    this.requestCallbacks.set(id, cb);
    return id;
  }

  public registerResponseEvent(cb: WeChatResponseCb): string {
    const id: string = util.generateRandomUUID(false);
    this.responseCallbacks.set(id, cb);
    return id;
  }

  public unregisterRequestEvent(callbackId: string): void {
    this.requestCallbacks.remove(callbackId);
  }

  public unregisterResponseEvent(callbackId: string): void {
    this.responseCallbacks.remove(callbackId);
  }

  public unregisterAllRequestEvents(): void {
    this.requestCallbacks.clear();
  }

  public unregisterAllResponseEvents(): void {
    this.responseCallbacks.clear();
  }

  public onReq(req: wxopensdk.BaseReq): void {
    this.requestCallbacks.forEach((cb: WeChatRequestCb): void => cb(req));
  }

  public onResp(resp: wxopensdk.BaseResp): void {
    this.responseCallbacks.forEach((cb: WeChatResponseCb): void => cb(resp));
  }
}

export const wechatEventHandler: WechatEventHandler = new WechatEventHandler();
