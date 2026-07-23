import { BaseViewModel, GlobalContext, PreferenceUtils, RouterMap, RouterUtils } from 'lib_common';
import { agreePrivacyKey } from '../common/Constants';

@ObservedV2
export class SafePageVM extends BaseViewModel {
  // todo: 自行调整是否支持开屏广告
  @Trace isShowAd: boolean = false;

  privacyClick() {
    RouterUtils.pushPathByName(RouterMap.PRIVACY_PAGE);
  }

  agreeBtnClick() {
    PreferenceUtils.getInstance().put(agreePrivacyKey, true);
    RouterUtils.clearStack();
    const targetPage = this.isShowAd ? RouterMap.SPLASH_PAGE : RouterMap.INDEX_PAGE;
    RouterUtils.pushPathByName(targetPage, null, undefined, false);
  }

  cancelBtnClick() {
    RouterUtils.pushPathByName(RouterMap.AGREE_PRIVACY_PAGE);
  }

  quitApp() {
    GlobalContext.getContext().getApplicationContext().killAllProcesses();
  }
}
