import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { LogUtil } from './LogUtil';

export class PreferenceUtil {
  private static preferenceRecord: Map<string, PreferenceUtil> = new Map()
  private dataPreferences: preferences.Preferences | null = null

  private constructor(context: Context, fileName: string) {
    preferences.removePreferencesFromCacheSync(context, fileName)
    this.dataPreferences = preferences.getPreferencesSync(context, { name: fileName })
    LogUtil.info(`PreferenceUtil: ${fileName} init: ${this.dataPreferences != null}`)
  }

  public static getInstance(context?: Context, fileName: string = 'default') {
    if (PreferenceUtil.preferenceRecord.has(fileName)) {
      return PreferenceUtil.preferenceRecord.get(fileName)!!
    }
    let ctx = context || getContext() as common.UIAbilityContext
    let preferenceUtil: PreferenceUtil = new PreferenceUtil(ctx, fileName);
    PreferenceUtil.preferenceRecord.set(fileName, preferenceUtil)
    return preferenceUtil
  }

  public put(key: string, value: object | string) {
    if (!this.dataPreferences) {
      LogUtil.info(`PreferenceUtil: dataPreferences is null`)
    }
    try {
      this.dataPreferences?.putSync(key, value)
      this.dataPreferences?.flushSync()
      LogUtil.info(`PreferenceUtil: put: ${key} = ${JSON.stringify(value)}`)
    } catch (e) {
      LogUtil.info(`PreferenceUtil: put error: ${JSON.stringify(e)}`)
    }
  }

  public get(key: string, defaultValue?: object | string) {
    try {
      let data = this.dataPreferences?.getSync(key, defaultValue)
      LogUtil.info(`PreferenceUtil: get: ${key} = ${JSON.stringify(data)}`)
      return data
    } catch (e) {
      LogUtil.info(`PreferenceUtil: get error: ${JSON.stringify(e)}`)
      return defaultValue
    }
  }

  public putToArray(key: string, value: string) {
    if (!this.dataPreferences) {
      LogUtil.info(`PreferenceUtil: dataPreferences is null`)
    }
    let array: Array<string> = this.get(key) as Array<string> || []
    if (array.indexOf(value) !== -1) {
      return
    }
    array.push(value)
    this.put(key, array)
  }

  public removeFromArray(key: string, value: string) {
    if (!this.dataPreferences) {
      LogUtil.info(`PreferenceUtil: dataPreferences is null`)
    }
    let array: Array<string> = this.get(key) as Array<string> || []
    array.splice(array.indexOf(value), 1)
    this.put(key, array)
  }
}