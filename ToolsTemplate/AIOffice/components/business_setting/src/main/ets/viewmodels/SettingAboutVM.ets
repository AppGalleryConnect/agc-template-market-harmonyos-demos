import { Want } from '@kit.AbilityKit';
import { BaseViewModel, TelephoneUtils, AppGalleryUtils, BundleInfo, GlobalContext, GlobalUtils } from 'lib_common';

@ObservedV2
export class SettingAboutVM extends BaseViewModel {
  @Trace appName: string = '';
  @Trace appVersionName: string = '';
  @Trace hasNewVersion: boolean = false;
  @Trace updateLabel: string = '检查更新'
  @Trace hotline: string = '000000';
  @Trace loading: boolean = false;

  constructor() {
    super();
    this.getBundleInfo();
  }

  async getBundleInfo() {
    let appInfo = AppStorage.get('appInfo') as BundleInfo
    this.appName = appInfo.appName
    this.appVersionName = appInfo.appVersionName;
  }

  checkUpdate() {
    const context = GlobalContext.getContext();
    this.loading = true;
    AppGalleryUtils.checkAppUpdate(context).then((resp: boolean) => {
      this.hasNewVersion = resp;
      this.updateLabel = this.hasNewVersion ? '存在新版本' : '已是最新版本';
      if (this.hasNewVersion) {
        AppGalleryUtils.showUpdateDialog(context);
      } else {
        GlobalContext.getUIContext().getPromptAction().showToast({ message: this.updateLabel });
      }
    }).finally(() => {
      this.loading = false;
    })
  }

  callHotline() {
    TelephoneUtils.callPhone(this.hotline);
  }

  goWebsite() {
    const context = GlobalContext.getContext();
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: 'https://beian.miit.gov.cn/#/home',
    }
    context.startAbility(want);
  }
}
