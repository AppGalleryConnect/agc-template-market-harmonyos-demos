import { bundleManager, common, Want } from '@kit.AbilityKit';
import { LayeredDrawableDescriptor } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { AppGalleryUtils } from '../common/AppGalleryUtils';
import { TelephoneUtils } from '../common/TelephoneUtils';
import { BaseViewModel } from '../models/BaseViewModel';

@ObservedV2
export class SettingAboutVM extends BaseViewModel {
  @Trace appName: string = '';
  @Trace appVersionName: string = '';
  @Trace appIcon: ResourceStr | PixelMap = '';
  @Trace hasNewVersion: boolean = false;
  @Trace updateLabel: string = '检查更新'
  @Trace hotline: string = '000000';
  @Trace loading: boolean = false;
  private context: common.UIAbilityContext;

  constructor(uiContext: UIContext) {
    super();
    this.context = uiContext.getHostContext() as common.UIAbilityContext;
    this.getBundleInfo();
  }

  async getBundleInfo() {
    const resource = this.context.resourceManager;
    try {
      const bundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      // 获取应用名称
      this.appName = resource.getStringSync(bundleInfo.appInfo.labelId);
      // 获取版本信息
      this.appVersionName = bundleInfo.versionName;
      // 获取应用图标
      const draw = resource.getDrawableDescriptor(bundleInfo.appInfo.iconId);
      const isLayered = draw instanceof LayeredDrawableDescriptor;
      if (isLayered) {
        let layered = draw as LayeredDrawableDescriptor;
        this.appIcon = layered.getPixelMap();
      } else {
        this.appIcon = resource.getMediaContentBase64Sync(bundleInfo.appInfo.iconId);
      }
    } catch (error) {
      UtilLog.error(0x000F, '[SettingAboutVM]',
        `Failed to get bundle info for self, errCode: ${error.code}, errMessage: ${error.message}`);
    }
  }

  checkUpdate() {
    this.loading = true;
    AppGalleryUtils.checkAppUpdate(this.context).then((resp: boolean) => {
      this.hasNewVersion = resp;
      this.updateLabel = this.hasNewVersion ? '存在新版本' : '已是最新版本';
      if (this.hasNewVersion) {
        AppGalleryUtils.showUpdateDialog(this.context);
      } else {
        promptAction.showToast({ message: this.updateLabel });
      }
    }).finally(() => {
      this.loading = false;
    })
  }

  callHotline() {
    TelephoneUtils.callPhone(this.hotline);
  }

  goWebsite() {
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: 'https://beian.miit.gov.cn/#/home',
    }
    this.context.startAbility(want).catch((err: BusinessError) => {
      UtilLog.error(0x000F, '[SettingAboutVM]',
        `Failed to start ability, errCode: ${err.code}, errMessage: ${err.message}`);
    });
  }
}
