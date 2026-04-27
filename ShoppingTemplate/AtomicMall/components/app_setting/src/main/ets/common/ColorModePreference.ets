import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';

export class ColorModePreference {
  private static readonly PREFERENCES_NAME: string = 'app_setting_preferences';
  private static readonly COLOR_MODE_INDEX_KEY: string = 'display_mode_index';

  public static getSavedColorModeIndex(context: common.UIAbilityContext | null): number {
    if (!context) {
      return -1;
    }
    try {
      const dataPreferences = preferences.getPreferencesSync(context, {
        name: ColorModePreference.PREFERENCES_NAME,
      });
      const savedIndex = dataPreferences.getSync(ColorModePreference.COLOR_MODE_INDEX_KEY, -1) as number;
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
        name: ColorModePreference.PREFERENCES_NAME,
      });
      dataPreferences.putSync(ColorModePreference.COLOR_MODE_INDEX_KEY, index);
      dataPreferences.flush();
    } catch (err) {
    }
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
}
