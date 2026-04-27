import { updateManager } from '@kit.AppGalleryKit';
import { common } from '@kit.AbilityKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { VersionModel } from '../model/Index';
import { AppStorageV2 } from '@kit.ArkUI';
import { call } from '@kit.TelephonyKit';


@ObservedV2
export class AboutPageVM {
  // todo 替换您应用的版本信息
  @Trace currentVersion: string = '1.0.0.2';
  @Trace appId: string = 'xxxx';
  @Trace versionInfo: VersionModel = AppStorageV2.connect(VersionModel, () => new VersionModel())!;
  @Trace phoneNumber: string = '900800';
  private static _instance: AboutPageVM;

  public static get instance() {
    if (!AboutPageVM._instance) {
      AboutPageVM._instance = new AboutPageVM();
    }
    return AboutPageVM._instance;
  }


  checkUpDate(ctx: UIContext, dialogController: CustomDialogController) {
    const context = ctx.getHostContext() as common.UIAbilityContext;
    try {
      updateManager.checkAppUpdate(context)
        .then((checkResult: updateManager.CheckUpdateResult) => {
          Logger.info('Succeeded in checking Result updateAvailable:' + checkResult.updateAvailable);
          if (checkResult.updateAvailable === updateManager.UpdateAvailableCode.LATER_VERSION_NOT_EXIST) {
            this.versionInfo.isLatestVersion = true;
          } else {
            this.versionInfo.isLatestVersion = false;
          }

          if (this.versionInfo.isLatestVersion) {
            ctx.getPromptAction().showToast({ message: '已是更新版本！' });
          } else {
            this.showUpdateDialog(ctx, dialogController);
          }

        }).catch((error: BusinessError) => {
        Logger.error(`checkAppUpdate onError.code is ${error.code}, message is ${error.message}`);
      });
    } catch (error) {
      Logger.error(`checkAppUpdate onError.code is ${error.code}, message is ${error.message}`);
    }
  }


  showUpdateDialog(ctx: UIContext, dialogController: CustomDialogController) {
    const context = ctx.getHostContext() as common.UIAbilityContext;
    try {
      updateManager.showUpdateDialog(context)
        .then((resultCode: updateManager.ShowUpdateResultCode) => {
          Logger.info('Succeeded in showing UpdateDialog resultCode:' + resultCode);
          // todo 升级弹框弹出失败时弹出模拟弹框
          if (resultCode === updateManager.ShowUpdateResultCode.SHOW_DIALOG_FAILURE) {
            dialogController.open();
          }
        })
        .catch((error: BusinessError) => {
          Logger.error(`showUpdateDialog onError.code is ${error.code}, message is ${error.message}`);
          // todo 升级弹框弹出失败时弹出模拟弹框
          dialogController.open();
        });
    } catch (error) {
      Logger.error(`showUpdateDialog onError.code is ${error.code}, message is ${error.message}`);
      // todo 升级弹框弹出失败时弹出模拟弹框
      dialogController.open();
    }
  }


  takePhone() {
    try {
      call.makeCall(this.phoneNumber,
        (err: BusinessError) => {
          if (err) {
            Logger.error(`makeCall fail, err->${JSON.stringify(err)}`);
          } else {
            Logger.info(`makeCall success`);
          }
        });
    } catch (e) {
      Logger.error(`Failed to call makeCall. error: ${JSON.stringify(e)}`);
    }
  }
}