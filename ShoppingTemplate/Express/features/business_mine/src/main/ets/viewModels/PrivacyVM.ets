import { RouterModule } from 'lib_foundation';
import { RouterMap } from 'module_base';
import { privacy } from '../constants';

const TAG = '[PrivacyVM]';

@ObservedV2
export class PrivacyVM {
  private static _instance: PrivacyVM;
  @Trace public title: string = ''
  @Trace public text: string = privacy

  public static get instance() {
    if (!PrivacyVM._instance) {
      PrivacyVM._instance = new PrivacyVM();
    }
    return PrivacyVM._instance;
  }

  init() {
    const param = RouterModule.getNavParam<string>({
      url: RouterMap.PRIVACY_PAGE,
    });
    if (param) {
      this.title = param
    }
  }
}
