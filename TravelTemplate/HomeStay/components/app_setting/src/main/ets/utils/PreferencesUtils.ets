import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[PreferencesUtils]';
const DOMAIN = 0;
const PREFERENCES_NAME = 'app_services_config';

// 存储的Key
export const PREF_KEY_LAST_COMMENT_TIME = 'last_comment_dialog_time';

export class PreferencesUtils {
  private static instance: PreferencesUtils | null = null;
  private preferences: preferences.Preferences | null = null;
  private context: common.UIAbilityContext | null = null;

  private constructor() {}

  /**
   * 获取单例实例
   */
  static getInstance(): PreferencesUtils {
    if (!PreferencesUtils.instance) {
      PreferencesUtils.instance = new PreferencesUtils();
    }
    return PreferencesUtils.instance;
  }

  /**
   * 初始化 Preferences
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.preferences) {
      return;
    }
    this.context = context;
    try {
      this.preferences = await preferences.getPreferences(context, PREFERENCES_NAME);
      UtilLog.info(DOMAIN, TAG, 'Preferences initialized successfully');
    } catch (error) {
      UtilLog.error(DOMAIN, TAG, `Failed to initialize Preferences: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 保存数据
   */
  async put(key: string, value: preferences.ValueType): Promise<boolean> {
    if (!this.preferences) {
      UtilLog.error(DOMAIN, TAG, 'Preferences not initialized');
      return false;
    }
    try {
      await this.preferences.put(key, value);
      await this.preferences.flush();
      UtilLog.info(DOMAIN, TAG, `Saved data: ${key} = ${value}`);
      return true;
    } catch (error) {
      UtilLog.error(DOMAIN, TAG, `Failed to save data: ${key}`);
      return false;
    }
  }

  /**
   * 获取数据
   */
  async get(key: string, defaultValue: preferences.ValueType): Promise<preferences.ValueType> {
    if (!this.preferences) {
      UtilLog.error(DOMAIN, TAG, 'Preferences not initialized');
      return defaultValue;
    }
    try {
      const value = await this.preferences.get(key, defaultValue);
      return value;
    } catch (error) {
      UtilLog.error(DOMAIN, TAG, `Failed to get data: ${key}`);
      return defaultValue;
    }
  }

  /**
   * 删除数据
   */
  async delete(key: string): Promise<boolean> {
    if (!this.preferences) {
      return false;
    }
    try {
      await this.preferences.delete(key);
      await this.preferences.flush();
      return true;
    } catch (error) {
      UtilLog.error(DOMAIN, TAG, `Failed to delete data: ${key}`);
      return false;
    }
  }
}