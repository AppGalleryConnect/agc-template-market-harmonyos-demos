import { AbilityConstant, UIAbility, Want, Configuration } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { BundleUtils, Logger, WX_APPID, QQ_APPID } from 'lib_common';
import { ShareService } from 'lib_widget';
import { LoneTakeAnimationsTransition } from 'module_transition';
import { WXLoginService } from 'module_login';
import { MediaController } from 'module_audioplayer';
import { PreviewUtils } from 'module_imagepreview';
import { WantUtils } from '../common/WantUtils';
import { CloudPrefetchUtils } from '../common/CloudPrefetchUtils';
import { NetworkUtils } from '../common/NetworkUtils';
import { ContinueUtils } from '../common/ContinueUtils';
import { WindowUtils } from '../common/WindowUtils';
import { AppUtils } from '../common/AppUtils';

const TAG = '[PhoneAbility]';

export default class PhoneAbility extends UIAbility {
  // 标记是否需要执行windowStage.loadContent
  private needLoadContent: boolean = false;
  // 实例化登录服务
  private loginServiceImpl: WXLoginService = WXLoginService.create().initWX(WX_APPID);
  // 实例化分享服务
  private shareServiceImpl: ShareService =
    ShareService.create()
      .initWX(WX_APPID)
      .initQQ(QQ_APPID);

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    Logger.setLogConfig();
    Logger.info(TAG, 'Ability onCreate');
    this.setNeedLoadContent(true);
    ContinueUtils.disableContinue(this.context);
    this.handleWeChatCallIfNeed(want);
    WantUtils.handleAppLinkingWant(want);
    WantUtils.handleShortcutWant(want);
    WantUtils.handlePushCall(want);
    WantUtils.handleFormCardCall(want);
    WantUtils.handleRestoreCall(want, launchParam);
    CloudPrefetchUtils.functionPreload();
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onNewWant');
    this.setNeedLoadContent(false);
    this.handleWeChatCallIfNeed(want);
    WantUtils.handleAppLinkingWant(want);
    WantUtils.handleShortcutWant(want);
    WantUtils.handlePushWant(want);
    WantUtils.handleFormCardCall(want);
    WantUtils.handleRestoreCall(want, launchParam);
  }

  onContinue(wantParam: Record<string, Object>) {
    Logger.info(TAG, 'Ability onContinue');
    return ContinueUtils.handleContinue(wantParam, this.context);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'Ability onWindowStageCreate');
    this.handleWindowStageCreateOrRestore(windowStage);
  }

  onWindowStageRestore(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'Ability onWindowStageRestore');
    if (this.needLoadContent) {
      this.handleWindowStageCreateOrRestore(windowStage);
    }
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    AppUtils.listenConfigurationUpdate(newConfig);
  }

  onWindowStageDestroy(): void {
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
    WindowUtils.offAvoidAreaChange();
    NetworkUtils.unRegisterNetwork();
  }

  // 微信回调事件处理
  handleWeChatCallIfNeed(want: Want) {
    this.loginServiceImpl.handleWant(want);
    this.shareServiceImpl.handleWant(want, this.context);
  }

  handleWindowStageCreateOrRestore(windowStage: window.WindowStage) {
    windowStage.loadContent('pages/Index').then(() => {
      Logger.info(TAG, 'Succeeded in loading the content.');
      WindowUtils.setWinConfig(windowStage);
      AppUtils.setAppTheme();
      AppUtils.setColorMode(this.context);
      BundleUtils.getBundleInfo(this.context);
      MediaController.setWindowStage(windowStage)
      LoneTakeAnimationsTransition.init(windowStage);
      PreviewUtils.initStage(windowStage)
      // 判断是否是模拟器
      let productMode = deviceInfo.productModel;
      if (productMode !== 'emulator') {
        NetworkUtils.initNetwork();
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, 'Failed to load the content. Cause: ' + JSON.stringify(err));
    })
  }

  setNeedLoadContent(value: boolean) {
    this.needLoadContent = value;
  }
};
