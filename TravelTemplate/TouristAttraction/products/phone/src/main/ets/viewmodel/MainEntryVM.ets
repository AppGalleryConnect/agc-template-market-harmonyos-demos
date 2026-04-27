import { UIContext } from '@kit.ArkUI';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { AccountUtil, AppPrivacyUtils } from 'common';

@ObservedV2
export class MainEntryVM {
  private static _instance: MainEntryVM;
  @Trace privacyImpl: AppPrivacyUtils = AppPrivacyUtils.instance;

  public static get instance() {
    if (!MainEntryVM._instance) {
      MainEntryVM._instance = new MainEntryVM();
    }
    return MainEntryVM._instance;
  }

  @Monitor('privacyImpl.agreeFlag')
  agreeFlagChange(uiContext: UIContext) {
    if (this.privacyImpl.agreeFlag) {
      Logger.info('user has agree the privacy, start silent login and apply permission');
      // 登录
      AccountUtil.initLogin(uiContext).then(() => {
        AccountUtil.getUserInfo();
      });
    }
  }

  public init(uiContext: UIContext) {
    this.agreeFlagChange(uiContext);
  }
}