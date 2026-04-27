import { preferences } from '@kit.ArkData';
import { UtilLog } from '@hw-agconnect/util-log';
import Logger from './Logger';

const TAG = '[PreferenceUtils]';

/**
 * 持久化管理类
 */
export class PreferenceUtils {
  private static preferenceRecord: Map<string, PreferenceUtils> = new Map();
  private dataPreferences: preferences.Preferences | null = null;

  private constructor(context: Context, fileName: string) {
    try {
      preferences.removePreferencesFromCacheSync(context, fileName);
      this.dataPreferences = preferences.getPreferencesSync(context, { name: fileName });
      Logger.info(TAG, `PreferenceUtil: ${fileName} init: ${this.dataPreferences !== null}`);
    } catch (e) {
      UtilLog.error(`remove preference error ${JSON.stringify(e)}`);
    }
  }

  public static getInstance(context?: Context, fileName: string = 'default') {
    if (PreferenceUtils.preferenceRecord.has(fileName)) {
      return PreferenceUtils.preferenceRecord.get(fileName)!!;
    }
    let ctx = context;
    let preferenceUtil: PreferenceUtils = new PreferenceUtils(ctx!, fileName);
    PreferenceUtils.preferenceRecord.set(fileName, preferenceUtil);
    return preferenceUtil;
  }

  public put(key: string, value: Object | string | boolean) {
    if (!this.dataPreferences) {
      Logger.info(TAG, 'PreferenceUtil: dataPreferences is null');
    }
    try {
      this.dataPreferences?.putSync(key, value);
      this.dataPreferences?.flush();
      Logger.info(TAG, `PreferenceUtil: put: ${key} = ${JSON.stringify(value)}`)
    } catch (e) {
      Logger.info(TAG, `PreferenceUtil: put error: ${JSON.stringify(e)}`);
    }
  }

  public get(key: string, defaultValue?: Object | string | boolean) {
    try {
      let data = this.dataPreferences?.getSync(key, defaultValue);
      Logger.info(TAG, `PreferenceUtil: get: ${key} = ${JSON.stringify(data)}`);
      return data;
    } catch (e) {
      Logger.info(TAG, `PreferenceUtil: get error: ${JSON.stringify(e)}`);
      return defaultValue;
    }
  }
}