import { common, Want } from '@kit.AbilityKit';
import { WXAPIFactory } from '@tencent/wechat_open_sdk';
import { IQQOpenApi, QQOpenApiFactory } from '@tencent/qq-open-sdk';
import { WBAPI } from 'core';
import { WXApiEventHandlerImpl } from './model/WXApiWrap';

export class ShareService {
  private static _instance: ShareService;
  public wxApi = WXAPIFactory.createWXAPI('');
  public wxEventHandler = new WXApiEventHandlerImpl();
  public qqOpenApi: IQQOpenApi = QQOpenApiFactory.createApi(0);

  /**
   * 创建实例
   * @returns
   */
  static create(): ShareService {
    ShareService._instance = new ShareService();
    return ShareService._instance;
  }

  /**
   * 获取实例
   * @returns
   */
  static get instance(): ShareService {
    if (!ShareService._instance) {
      ShareService._instance = new ShareService();
    }
    return ShareService._instance;
  }

  /**
   * 初始化微信SDK
   * @param appId
   * @returns
   */
  public initWX(appId: string): ShareService {
    this.wxApi = WXAPIFactory.createWXAPI(appId);
    return this;
  }

  /**
   * 初始化QQ SDK
   * @param appId
   * @returns
   */
  public initQQ(appId: number): ShareService {
    this.qqOpenApi = QQOpenApiFactory.createApi(appId, {
      forceEnableWeb: false,
      autoHandleAuthResult: true,
    });
    return this;
  }

  /**
   * 处理被分享应用的want信息
   * @param want
   */
  public handleWant(want: Want, context: common.UIAbilityContext): void {
    this.wxApi.handleWant(want, this.wxEventHandler);
    this.qqOpenApi.handleResult(want);
    WBAPI.getInstance().doWBAsResult(want, context);
  }
}
