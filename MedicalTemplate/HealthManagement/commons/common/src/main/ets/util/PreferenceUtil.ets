import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { TCLogger } from '../basic/TCLogger';
import { GlobalContext } from '../basic/GlobalContext';
import { TValueType } from '../../../../Index';

const TAG = 'PreferenceUtil';

export class PreferenceUtil {
  private static preferenceRecord: Map<string, PreferenceUtil> = new Map();
  private dataPreferences: preferences.Preferences | null = null;

  private constructor(context: Context, fileName: string) {
    try {
      preferences.removePreferencesFromCacheSync(context, fileName);
      this.dataPreferences = preferences.getPreferencesSync(context, { name: fileName });
      TCLogger.info(TAG, `${fileName} init: ${this.dataPreferences !== null}`);
    } catch (err) {
    }
  }

  public static getInstance(context?: Context, fileName: string = 'default') {
    if (PreferenceUtil.preferenceRecord.has(fileName)) {
      return PreferenceUtil.preferenceRecord.get(fileName)!!;
    }
    let ctx = context || GlobalContext.getUIAbilityContext() as common.UIAbilityContext;
    let preferenceUtil: PreferenceUtil = new PreferenceUtil(ctx, fileName);
    PreferenceUtil.preferenceRecord.set(fileName, preferenceUtil);
    return preferenceUtil;
  }


  public put(key: string, value: TValueType) {
    if (!this.dataPreferences) {
      TCLogger.info(TAG, 'dataPreferences is null');
    }
    try {
      this.dataPreferences?.putSync(key, value);
      this.dataPreferences?.flush();
      TCLogger.info(TAG, `put: ${key} = ${JSON.stringify(value)}`);
    } catch (e) {
      TCLogger.error(TAG, `put error: ${JSON.stringify(e)}`);
    }
  }

  public get(key: string, defaultValue?: TValueType) {
    try {
      let data = this.dataPreferences?.getSync(key, defaultValue);
      TCLogger.info(TAG, `get: ${key} = ${JSON.stringify(data)}`);
      return data;
    } catch (e) {
      TCLogger.error(TAG, `get error: ${JSON.stringify(e)}`);
      return defaultValue;
    }
  }

  public putToArray(key: string, value: string) {
    if (!this.dataPreferences) {
      TCLogger.info(TAG, 'dataPreferences is null');
    }
    let array: Array<string> = this.get(key) as Array<string> || [];
    if (array.indexOf(value) !== -1) {
      return;
    }
    array.push(value);
    this.put(key, array);
  }

  public removeFromArray(key: string, value: string) {
    if (!this.dataPreferences) {
      TCLogger.info(TAG, 'dataPreferences is null');
    }
    let array: Array<string> = this.get(key) as Array<string> || [];
    array.splice(array.indexOf(value), 1);
    this.put(key, array);
  }

  /**
   * 检查缓存的Preferences实例中是否包含名为给定Key的存储键值对
   * @param key
   * @returns
   */
  public has(key: string) {
    if (!this.dataPreferences) {
      TCLogger.info(TAG, 'dataPreferences is null');
    }

    return this.dataPreferences?.hasSync(key);
  }

  /**
   * 删除缓存值
   * @param key
   * @returns
   */
  public delete(key: string) {
    if (!this.dataPreferences) {
      TCLogger.info(TAG, 'dataPreferences is null');
    }

    this.dataPreferences?.deleteSync(key);
    return this.dataPreferences?.flush() //此处一定要flush，要不然不能永久序列化到本地
  }

  /**
   * 清空缓存
   * @param preferenceName
   * @returns
   */
  public clear() {
    if (!this.dataPreferences) {
      TCLogger.info(TAG, 'dataPreferences is null');
    }

    this.dataPreferences?.clearSync();
    return this.dataPreferences?.flush() //此处一定要flush，要不然不能永久序列化到本地
  }
}