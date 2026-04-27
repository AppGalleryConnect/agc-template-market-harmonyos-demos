import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointUtils, ContextUtil, PreferenceUtil, RouterMap, RouterModule } from 'lib_foundation';
import { PageRouterModel } from '../types';


@ObservedV2
export class IndexVM {
  @Trace navStack: NavPathStack = RouterModule.stack;
  @Trace pageRouter: PageRouterModel = AppStorageV2.connect(PageRouterModel, () => new PageRouterModel())!;
  breakpoint: BreakpointUtils | null = null;

  setInterception() {
    const res = PreferenceUtil.getInstance(ContextUtil.globalContext).get('SafePrivacy') as boolean

    if (res) {
      // 针对桌面图标跳转处理
      if (this.pageRouter.shortcutId) {
        RouterModule.replace({ url: RouterMap.MAIN_ENTRY })
        return;
      }
      // 跳转 广告页
      RouterModule.push({ url: RouterMap.SPLASH_PAGE })
      return
    }
    // 如果未同意隐私则不跳转到桌面图标对应的页面
    this.pageRouter.shortcutId = '';
    RouterModule.push({ url: RouterMap.SAFE_PAGE })
  }

  registerBreakpointListener(uiContext: UIContext) {
    this.breakpoint = new BreakpointUtils(uiContext.getMediaQuery());
    this.breakpoint?.register();
  }
}
