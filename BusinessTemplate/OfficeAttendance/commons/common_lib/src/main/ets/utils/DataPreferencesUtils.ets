import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

type ValueType = number | string | boolean | Array<number> | Array<string> | Array<boolean> | Uint8Array | object
  | bigint;

export class DataPreferencesUtils {
  public static readonly LUNAR_SETTING = 'lunarSetting';

  public static readonly LUNAR_SETTING_ON = 1;

  public static readonly LUNAR_SETTING_OFF = 0;

  private static dataPreferences: preferences.Preferences | null = null;

  public static init(context: common.UIAbilityContext, options: preferences.Options): void {
    DataPreferencesUtils.dataPreferences = preferences.getPreferencesSync(context, options);
  }

  public static putSync(key: string, value: ValueType): void {
    DataPreferencesUtils.dataPreferences?.putSync(key, value);
    DataPreferencesUtils.dataPreferences?.flushSync();
  }

  public static getSync(key: string, defValue: ValueType): ValueType | undefined {
    return DataPreferencesUtils.dataPreferences?.getSync(key, defValue);
  }
}
