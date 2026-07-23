import { Configuration } from '@kit.AbilityKit';
import { PersistenceV2, ThemeControl } from '@kit.ArkUI';
import { GlobalContext, Logger, SettingModel, SystemBarOperation } from 'lib_common';
import { gAppTheme } from './AppTheme';

const TAG = 'AppUtils';

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
  public static setColorMode() {
    Logger.info(TAG, 'setColorMode PersistenceV2 keys: ' + JSON.stringify(PersistenceV2.keys()));
    const context = GlobalContext.getContext();
    const settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
    context.getApplicationContext().setColorMode(settingInfo.colorMode);
  }

  /**
   * 订阅环境变量
   */
  public static listenConfigurationUpdate(newConfig: Configuration) {
    const settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
    settingInfo.darkSwitch = newConfig.colorMode === 0;
    SystemBarOperation.setWindowSystemBarProp({
      statusBarContentColor: settingInfo.darkSwitch ? '#ffffff' : '#ff090909',
    });
  }
}