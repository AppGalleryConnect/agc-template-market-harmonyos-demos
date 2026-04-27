import { RouterModule } from 'lib_foundation'
import { contextUtil, PreferenceUtil, RouterMap } from 'module_base';

@ObservedV2
export class SafePageVM {
  privacyClick() {
    RouterModule.push({ url: RouterMap.PRIVACY_PAGE });
  }

  agreeBtnClick() {
    PreferenceUtil.getInstance().put('SafePrivacy', true)
    RouterModule.clear()
    RouterModule.push({ url: RouterMap.MAIN_ENTRY });
  }

  cancelBtnClick() {
    RouterModule.push({ url: RouterMap.AGREE_PRIVACY_PAGE });
  }

  quitApp() {
    contextUtil.getContext()?.getApplicationContext().killAllProcesses();
  }
}
