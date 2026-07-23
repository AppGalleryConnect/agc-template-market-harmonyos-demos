import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointUtils, PreferConstant, PreferenceUtil, RouterMap, RouterModule } from 'commonlib';
import { FormCardJumpModel } from '../models/Types';


@ObservedV2
export class IndexVM {
  @Trace navStack: NavPathStack = RouterModule.stack;
  @Trace formModel: FormCardJumpModel = AppStorageV2.connect(FormCardJumpModel, () => new FormCardJumpModel())!;
  breakpoint: BreakpointUtils | null = null;

  setInterception() {
    let privacyState = PreferenceUtil.getInstance().get(PreferConstant.PRIVACY_POLICY_KEY, '0')

    if (privacyState === '1') {
      if (this.formModel.formCardPageUrl) {
        RouterModule.replace({ url: RouterMap.MAIN_ENTRY })
        return;
      }
      // 跳转 广告页
      RouterModule.push({ url: RouterMap.SPLASH_PAGE });
    } else {
      // 跳转隐私页
      RouterModule.push({ url: RouterMap.PRIVACY_POLICY_PAGE });
    }
  }

  registerBreakpointListener(uiContext: UIContext) {
    this.breakpoint = new BreakpointUtils(uiContext.getMediaQuery());
    this.breakpoint?.register();
  }

  unregisterBreakpointListener() {
    this.breakpoint?.unRegister();
  }
}
