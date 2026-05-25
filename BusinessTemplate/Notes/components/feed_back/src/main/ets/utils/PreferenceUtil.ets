import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Logger';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class PreferConstant {
  //意见反馈记录
  static readonly FEEDBACK_RECORD: string = 'FEEDBACK_RECORD';
}

export class PreferenceUtil {
  private static preferenceRecord: Map<string, PreferenceUtil> = new Map();
  private dataPreferences: preferences.Preferences | null = null;

  private constructor(context: Context, fileName: string) {
    try {
      preferences.removePreferencesFromCacheSync(context, fileName);
      this.dataPreferences = preferences.getPreferencesSync(context, { name: fileName });
      Logger.info(`PreferenceUtil: ${fileName} init: ${this.dataPreferences != null}`);
    } catch (error) {
      const err = error as BusinessError;
      Logger.info(`PreferenceUtil: ${fileName} init error, code: ${err.code}, message: ${err.message}`);
      this.dataPreferences = null;
    }
  }

  public static getInstance(context: Context, fileName: string = 'default') {
    if (PreferenceUtil.preferenceRecord.has(fileName)) {
      return PreferenceUtil.preferenceRecord.get(fileName)!!;
    }
    let preferenceUtil: PreferenceUtil = new PreferenceUtil(context, fileName);
    PreferenceUtil.preferenceRecord.set(fileName, preferenceUtil);
    return preferenceUtil;
  }

  public put(key: string, value: preferences.ValueType) {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`);
    }
    try {
      this.dataPreferences?.putSync(key, value);
      this.dataPreferences?.flush();
      Logger.info(`PreferenceUtil: put: ${key} = ${JSON.stringify(value)}`);
    } catch (e) {
      Logger.info(`PreferenceUtil: put error: ${JSON.stringify(e)}`);
    }
  }

  public get(key: string, defaultValue?: preferences.ValueType) {
    try {
      let data = this.dataPreferences?.getSync(key, defaultValue);
      Logger.info(`PreferenceUtil: get: ${key} = ${JSON.stringify(data)}`);
      return data;
    } catch (e) {
      Logger.info(`PreferenceUtil: get error: ${JSON.stringify(e)}`);
      return defaultValue;
    }
  }

  public hasSync(key: string): boolean {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`);
      return false;
    }
    return this.dataPreferences?.hasSync(key);
  }

  public getAllSync(): object | null {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`);
      return null;
    }
    return this.dataPreferences.getAllSync();
  }

  public delete(key: string) {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`);
      return;
    }
    try {
      // 删除
      this.dataPreferences?.deleteSync(key);
      this.dataPreferences?.flush();
      hilog.info(0x0000, 'PreferenceUtil', `删除Preferences key=${key} 成功`);
    } catch (e) {
      hilog.error(0x0000, 'PreferenceUtil', `删除Preferences key=${key} 失败: ${JSON.stringify(e)}`);
    }
  }

  isClean(): boolean {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`);
      return true;
    }
    let arr: [] = [];
    let value = this.dataPreferences.getAllSync();
    if (value) {
      arr = Object.values(value) as [];
    }
    if (arr.length === 0) {
      return true;
    }
    return false;
  }

  clear() {
    if (!this.dataPreferences) {
      Logger.info(`PreferenceUtil: dataPreferences is null`);
      return;
    }
    try {
      this.dataPreferences.clearSync();
      this.dataPreferences?.flush();
    } catch (e) {
      hilog.error(0x0000, 'PreferenceUtil', `clear失败: ${JSON.stringify(e)}`);
    }
  }
}

