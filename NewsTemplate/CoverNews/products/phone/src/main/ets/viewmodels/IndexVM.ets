import { authentication } from '@kit.AccountKit';
import { AccountUtils } from 'atomicservice_login';
import { AppPrivacyUtils, BaseViewModel, BreakpointUtils, Logger, RouterMap, RouterUtils } from 'lib_common';

const TAG = '[IndexVM]';

@ObservedV2
export class IndexVM extends BaseViewModel {
  public privacyImpl: AppPrivacyUtils = AppPrivacyUtils.instance;
  public breakpoint: BreakpointUtils | null = null;

  redirect() {
    if (this.privacyImpl.CONFIG_SHOW_HOME || this.privacyImpl.agreeFlag) {
      RouterUtils.replacePathByName(RouterMap.INDEX_PAGE);
    }
  }

  silentLogin() {
    if (this.privacyImpl.agreeFlag) {
      AccountUtils.silentLogin((data?: authentication.LoginWithHuaweiIDCredential) => {
        Logger.info(TAG, `Success to silent login, result: ${JSON.stringify(data)}`);
      })
    }
  }

  @Monitor('privacyImpl.agreeFlag')
  agreeFlagChange() {
    if (!this.privacyImpl.CONFIG_SHOW_HOME && this.privacyImpl.agreeFlag) {
      RouterUtils.replacePathByName(RouterMap.INDEX_PAGE);
    }
    this.silentLogin();
  }
}