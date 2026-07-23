import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { ShareService } from 'aggregated_share';
import { ContextUtil, Logger, RdbUtil, WindowUtil } from 'commonlib';
import { FormCardJumpModel } from '../models/Types';

const TAG = '[EntryAbility]';

export default class PhoneAbility extends UIAbility {

  // 实例化分享服务
  private shareServiceImpl: ShareService =
    ShareService.create()
    // todo 填写微信开放平台配置的应用AppID
      .initWX('111111111')
      // todo 填写QQ互联平台配置的应用AppID
      .initQQ(111111111);

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onCreate');
    AppStorage.setOrCreate('context', this.context)
    // 全局设置为浅色模式
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    } catch (err) {
      Logger.info(TAG, `Failed to set colorMode. Cause: ${JSON.stringify(err)}`);
    }

    this.handleFormWant(want);
    this.shareServiceImpl.handleWant(want, this.context);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'Ability onWindowStageCreate');
    // 数据库初始化
    RdbUtil.initDB(this.context);
    windowStage.loadContent('pages/Index').then(() => {
      Logger.info(TAG, 'Succeeded in loading the content.');
      try {
        ContextUtil.setUIContext('EntryAbility', windowStage.getMainWindowSync().getUIContext());
      } catch (e) {
        Logger.error(TAG, 'Failed to getMainWindowSync. Cause: %{public}s', JSON.stringify(e) ?? '');
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, 'Failed to load the content. Cause: ' + JSON.stringify(err));
    })

    WindowUtil.setWinConfig(windowStage);
  }

  onNewWant(want: Want): void {
    this.handleFormWant(want);
    this.shareServiceImpl.handleWant(want, this.context);
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
    WindowUtil.offAvoidAreaChange();
    WindowUtil.offWindowSizeChange();
    WindowUtil.offWindowStatusChange();
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info(TAG, 'Ability onBackground');
  }

  handleFormWant(want: Want) {
    const formModel: FormCardJumpModel = AppStorageV2.connect(FormCardJumpModel, () => new FormCardJumpModel())!;
    // 参数解析
    let params = want?.parameters;
    // 服务卡片
    if (params?.source === 'FormCard') {
      formModel.formCardId = Date.now().toString();
      const pageUrl = params?.pageUrl && typeof params.pageUrl === 'string' ? params.pageUrl : '';
      formModel.formCardPageUrl = pageUrl
      return;
    }
  }
}