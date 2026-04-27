import { RouterModule } from 'lib_foundation';
import { PreferenceUtil, RouterMap } from 'module_base';

const TAG = 'IndexVM';

@ObservedV2
export class IndexVM {
  @Trace navStack: NavPathStack = RouterModule.stack;

  setInterception() {
    const res = PreferenceUtil.getInstance().get('SafePrivacy') as boolean

    if (res) {
      RouterModule.push({ url: RouterMap.MAIN_ENTRY })
      return
    }
    RouterModule.push({ url: RouterMap.SAFE_PAGE })
  }
}
