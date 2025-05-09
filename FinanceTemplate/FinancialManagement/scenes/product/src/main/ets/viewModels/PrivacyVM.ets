import { RouterMap, RouterModule } from 'commonlib';
import { privacyProduct } from '../constants';

const TAG = '[PrivacyVM]';

@ObservedV2
export class PrivacyVM {
  private static _instance: PrivacyVM;
  @Trace public title: string = ''
  @Trace public text: string = privacyProduct

  public static get instance() {
    if (!PrivacyVM._instance) {
      PrivacyVM._instance = new PrivacyVM();
    }
    return PrivacyVM._instance;
  }

  init() {
    const param = RouterModule.getNavParam<string>({
      url: RouterMap.PRIVACY,
    });
    if (param) {
      this.title = param
    }
  }
}
