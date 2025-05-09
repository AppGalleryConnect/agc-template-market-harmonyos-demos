import { https } from 'network';
import { AccountUtil, AppStorageMap, FormatUtil, Logger, RouterMap, RouterModule, UserInfoModel, } from 'commonlib';

const TAG = '[PreviewVM]';

@ObservedV2
export class PreviewVM {
  private static _instance: PreviewVM;
  @Trace public url: string = ''

  public static get instance() {
    if (!PreviewVM._instance) {
      PreviewVM._instance = new PreviewVM();
    }
    return PreviewVM._instance;
  }

  init() {
    const param = RouterModule.getNavParam<string>({
      url: RouterMap.PREVIEW,
    });
    if (param) {
      this.url = param
    }
  }

  clear() {
    this.url = ''
  }
}
