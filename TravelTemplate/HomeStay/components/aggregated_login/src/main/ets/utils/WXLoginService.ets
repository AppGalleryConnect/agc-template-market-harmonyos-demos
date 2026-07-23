import { Want } from '@kit.AbilityKit';
import * as wxopensdk from '@tencent/wechat_open_sdk';
import { wxEventHandler } from './WXApiUtils';

export class WXLoginService {
  private static _instance: WXLoginService;
  public wxApi: wxopensdk.WXApi = wxopensdk.WXAPIFactory.createWXAPI('');

  /**
   * 创建实例
   * @returns
   */
  static create(): WXLoginService {
    WXLoginService._instance = new WXLoginService();
    return WXLoginService._instance;
  }

  /**
   * 获取实例
   * @returns
   */
  static get instance(): WXLoginService {
    if (!WXLoginService._instance) {
      WXLoginService._instance = new WXLoginService();
    }
    return WXLoginService._instance;
  }

  /**
   * 初始化微信SDK
   * @param appId
   * @returns
   */
  public initWX(appId: string): WXLoginService {
    this.wxApi = wxopensdk.WXAPIFactory.createWXAPI(appId);
    return this;
  }

  /**
   * 处理被分享应用的want信息
   * @param want
   */
  public handleWant(want: Want): void {
    this.wxApi.handleWant(want, wxEventHandler);
  }
}
