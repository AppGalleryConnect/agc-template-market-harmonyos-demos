import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';

export class ColorModeUtil {
  private static readonly PREFERENCES_NAME: string = 'app_setting_preferences';
  private static readonly COLOR_MODE_INDEX_KEY: string = 'display_mode_index';

  public static getSavedColorModeIndex(context: common.UIAbilityContext | null): number {
    if (!context) {
      return -1;
    }
    try {
      const dataPreferences = preferences.getPreferencesSync(context, {
        name: ColorModeUtil.PREFERENCES_NAME,
      });
      const savedIndex = dataPreferences.getSync(ColorModeUtil.COLOR_MODE_INDEX_KEY, -1) as number;
      if (savedIndex >= 0 && savedIndex <= 2) {
        return savedIndex;
      }
    } catch (err) {
    }
    return -1;
  }

  public static saveColorModeIndex(context: common.UIAbilityContext | null, index: number): void {
    if (!context || index < 0 || index > 2) {
      return;
    }
    try {
      const dataPreferences = preferences.getPreferencesSync(context, {
        name: ColorModeUtil.PREFERENCES_NAME,
      });
      dataPreferences.putSync(ColorModeUtil.COLOR_MODE_INDEX_KEY, index);
      dataPreferences.flush();
    } catch (err) {
    }
  }

  public static getColorModeByIndex(index: number): ConfigurationConstant.ColorMode {
    if (index === 1) {
      return ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
    }
    if (index === 2) {
      return ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    }
    return ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  }

  public static getColorModeIndexByMode(mode: ConfigurationConstant.ColorMode): number {
    if (mode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      return 1;
    }
    if (mode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      return 2;
    }
    return 0;
  }

  public static applySavedColorMode(context: common.UIAbilityContext | null): void {
    const savedIndex = ColorModeUtil.getSavedColorModeIndex(context);
    if (savedIndex < 0) {
      return;
    }
    const colorMode = ColorModeUtil.getColorModeByIndex(savedIndex);
    try {
      context?.getApplicationContext().setColorMode(colorMode);
    } catch (err) {
    }
  }
}
