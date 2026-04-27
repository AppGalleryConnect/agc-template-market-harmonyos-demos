import { common, Want, bundleManager } from '@kit.AbilityKit';
import { LayeredDrawableDescriptor } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger, WindowUtil } from 'module_ui_base';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { AppGalleryUtils } from '../common/AppGalleryUtils';
import { TelephoneUtils } from '../common/TelephoneUtils';
import { LOG_TAG } from '../constants/CommonConstants';
import { BaseViewModel } from '../models/BaseViewModel';

@ObservedV2
export class SettingAboutVM extends BaseViewModel {
  @Trace appName: string = '';
  @Trace appVersionName: string = '';
  @Trace appIcon: ResourceStr | PixelMap = '';
  @Trace hasNewVersion: boolean = false;
  @Trace updateLabel: string = '检查更新';
  @Trace hotline: string = '000000';
  @Trace loading: boolean = false;

  constructor() {
    super();
    this.getBundleInfo();
  }

  async getBundleInfo() {
    if (!WindowUtil.context) {
      return;
    }
    try {
      const resource = WindowUtil.context.resourceManager;
      const bundleInfo = await bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION,
      );
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
        this.appIcon = resource.getMediaContentBase64Sync(
          bundleInfo.appInfo.iconId,
        );
      }
    } catch (err) {
      Logger.error(LOG_TAG, 'get bundle info failed. error: ' + JSON.stringify(err));
    }
  }

  checkUpdate() {
    const context = WindowUtil.context as common.UIAbilityContext;
    this.loading = true;
    AppGalleryUtils.checkAppUpdate(context)
      .then((resp: boolean) => {
        this.hasNewVersion = resp;
        this.updateLabel = this.hasNewVersion ? '存在新版本' : '已是最新版本';
        if (this.hasNewVersion) {
          AppGalleryUtils.showUpdateDialog(context);
        } else {
          promptAction.showToast({ message: this.updateLabel });
        }
      })
      .finally(() => {
        this.loading = false;
      });
  }

  callHotline() {
    TelephoneUtils.callPhone(this.hotline);
  }

  goWebsite() {
    const context = WindowUtil.context as common.UIAbilityContext;
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: 'https://beian.miit.gov.cn/#/home',
    };
    context.startAbility(want).catch((err: BusinessError) => {
      Logger.error(LOG_TAG, 'start ability failed. error:' + JSON.stringify(err));
    });
  }
}
