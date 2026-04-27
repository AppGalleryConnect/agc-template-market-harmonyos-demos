import { AppStorageV2 } from '@kit.ArkUI';
import { ContextUtil, PreferenceUtil, RouterMap, RouterModule, WindowInfo } from 'lib_foundation';

@ObservedV2
export class SafePageVM {
  @Trace windowModel: WindowInfo = AppStorageV2.connect(WindowInfo, () => new WindowInfo())!;
  @Trace openSheet: boolean = false;

  privacyClick() {
    RouterModule.push({ url: RouterMap.PRIVACY_PAGE });
  }

  agreeBtnClick() {
    PreferenceUtil.getInstance(ContextUtil.globalContext).put('SafePrivacy', true)
    RouterModule.replace({ url: RouterMap.SPLASH_PAGE });
  }

  quitApp() {
    ContextUtil.globalContext?.getApplicationContext().killAllProcesses();
  }
}
