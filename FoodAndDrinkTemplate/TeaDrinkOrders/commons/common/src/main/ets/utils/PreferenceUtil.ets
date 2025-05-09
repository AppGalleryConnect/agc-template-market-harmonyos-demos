import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { logger } from './Logger';

export class PreferenceUtil {
  private static preferenceRecord: Map<string, PreferenceUtil> = new Map()
  private dataPreferences: preferences.Preferences | null = null

  private constructor(context: Context, fileName: string) {
    preferences.removePreferencesFromCacheSync(context, fileName)
    this.dataPreferences = preferences.getPreferencesSync(context, { name: fileName })
    logger.info(`PreferenceUtil: ${fileName} init: ${this.dataPreferences != null}`)
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
      logger.info(`PreferenceUtil: dataPreferences is null`)
    }
    try {
      this.dataPreferences?.putSync(key, value)
      this.dataPreferences?.flush()
      logger.info(`PreferenceUtil: put: ${key} = ${JSON.stringify(value)}`)
    } catch (e) {
      logger.info(`PreferenceUtil: put error: ${JSON.stringify(e)}`)
    }
  }

  public get(key: string, defaultValue?: object | string) {
    try {
      let data = this.dataPreferences?.getSync(key, defaultValue)
      logger.info(`PreferenceUtil: get: ${key} = ${JSON.stringify(data)}`)
      return data
    } catch (e) {
      logger.info(`PreferenceUtil: get error: ${JSON.stringify(e)}`)
      return defaultValue
    }
  }

  public putToArray(key: string, value: string) {
    if (!this.dataPreferences) {
      logger.info(`PreferenceUtil: dataPreferences is null`)
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
      logger.info(`PreferenceUtil: dataPreferences is null`)
    }
    let array: Array<string> = this.get(key) as Array<string> || []
    array.splice(array.indexOf(value), 1)
    this.put(key, array)
  }
}