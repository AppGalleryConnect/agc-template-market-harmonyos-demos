import { common, Configuration } from '@kit.AbilityKit';
import { PersistenceV2, ThemeControl } from '@kit.ArkUI';
import { Logger, SettingModel, SystemBarOperation } from 'lib_common';
import { gAppTheme } from './AppTheme';

const TAG = '[AppUtils]';

/**
 * 应用设置工具类
 */
export class AppUtils {
  /**
   * 设置应用主题色
   */
  public static setAppTheme() {
    ThemeControl.setDefaultTheme(gAppTheme);
  }

  /**
   * 设置应用深浅色
   */
  public static setColorMode(context: common.UIAbilityContext) {
    Logger.info(TAG, 'setColorMode PersistenceV2 keys: ' + JSON.stringify(PersistenceV2.keys()));
    const settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
    try {
      context.getApplicationContext().setColorMode(settingInfo.colorMode);
    } catch (error) {
      Logger.error(TAG, 'setColorMode fail, error: ' + JSON.stringify(error));
    }
  }

  /**
   * 订阅环境变量
   */
  public static listenConfigurationUpdate(newConfig: Configuration) {
    const settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
    const oldValue = settingInfo.darkSwitch;
    settingInfo.darkSwitch = newConfig.colorMode === 0;
    if (settingInfo.darkSwitch !== oldValue) {
      SystemBarOperation.setWindowSystemBarProp({
        statusBarContentColor: settingInfo.darkSwitch ? '#ffffff' : '#ff090909',
      });
    }
  }
}