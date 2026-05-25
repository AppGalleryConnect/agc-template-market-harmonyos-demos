import { BaseViewModel, PreferenceUtils, RouterMap, RouterUtils } from 'lib_common';
import { agreePrivacyKey, skipGuide } from '../common/Constants';
import { common } from '@kit.AbilityKit';

@ObservedV2
export class SafePageVM extends BaseViewModel {
  isSkipGuide() {
    return PreferenceUtils.getInstance().get(skipGuide) as boolean;
  }

  privacyClick() {
    RouterUtils.pushPathByName(RouterMap.PRIVACY_PAGE);
  }

  agreeBtnClick() {
    PreferenceUtils.getInstance().put(agreePrivacyKey, true);
    RouterUtils.clearStack();
    if (this.isSkipGuide()) {
      const targetPage = RouterMap.INDEX_PAGE;
      RouterUtils.pushPathByName(targetPage, null, undefined, false);
    } else {
      const targetPage1 = RouterMap.GUIDE_PAGE_Gender;
      RouterUtils.pushPathByName(targetPage1, null, undefined, false);
    }
  }

  cancelBtnClick() {
    RouterUtils.pushPathByName(RouterMap.AGREE_PRIVACY_PAGE);
  }

  quitApp(context: common.UIAbilityContext) {
    try {
      context.getApplicationContext().killAllProcesses();
    } catch (e) {
      console.error('killAllProcesses failed. Cause' + JSON.stringify(e))
    }
  }
}
