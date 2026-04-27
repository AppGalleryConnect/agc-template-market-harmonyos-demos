import { preferences } from '@kit.ArkData';
import { common, Context } from '@kit.AbilityKit';
import { Logger } from '../../logger/AppLogger';

export class PreferConstant {
  // 题目笔记
  static readonly TOPIC_NOTES: string = 'TOPIC_NOTES';
  // 错题记录
  static readonly ERROR_RECORDS: string = 'ERROR_RECORDS';
  // 收藏记录
  static readonly EXAM_PREFER_COLLECT: string = 'EXAM_PREFER_COLLECT';
  //意见反馈记录
  static readonly FEEDBACK_RECORD: string = 'FEEDBACK_RECORD';
  //首次进入启动页隐私协议状态
  static readonly FIRSTLAUNCH: string = 'FirstLaunch';
  // 视频清晰度设置
  static readonly VIDEO_QUALITY: string = 'VIDEO_QUALITY';
  // 是否允许后台播放
  static readonly BACKGROUND_PLAY: string = 'BACKGROUND_PLAY';
}

const TAG = 'PreferenceUtil'

export class PreferenceUtil {
  private static preferenceRecord: Map<string, PreferenceUtil> = new Map()
  private dataPreferences: preferences.Preferences | null = null

  private constructor(context: Context, fileName: string) {
    try {
      preferences.removePreferencesFromCacheSync(context, fileName)
      this.dataPreferences = preferences.getPreferencesSync(context, { name: fileName })
      Logger.info(TAG, `PreferenceUtil: ${fileName} init: ${this.dataPreferences != null}`)
    } catch (e) {
    }
  }

  public static getInstance(context:Context, fileName: string = 'default'):PreferenceUtil {
    if (PreferenceUtil.preferenceRecord.has(fileName)) {
      return PreferenceUtil.preferenceRecord.get(fileName)!!
    }
    let ctx = context as common.UIAbilityContext
    let preferenceUtil: PreferenceUtil = new PreferenceUtil(ctx, fileName);
    PreferenceUtil.preferenceRecord.set(fileName, preferenceUtil)
    return preferenceUtil
  }

  public put(key: string, value: preferences.ValueType):void {
    if (!this.dataPreferences) {
      Logger.info(TAG, `PreferenceUtil: dataPreferences is null`)
    }
    try {
      this.dataPreferences?.putSync(key, value)
      this.dataPreferences?.flush()
      Logger.info(TAG, `PreferenceUtil: put: ${key} = ${JSON.stringify(value)}`)
    } catch (e) {
      Logger.info(TAG, `PreferenceUtil: put error: ${JSON.stringify(e)}`)
    }
  }

  public get(key: string, defaultValue?: preferences.ValueType):preferences.ValueType {
    try {
      let data = this.dataPreferences?.getSync(key, defaultValue)
      Logger.info(TAG, `PreferenceUtil: get: ${key} = ${JSON.stringify(data)}`)
      return data
    } catch (e) {
      Logger.info(TAG, `PreferenceUtil: get error: ${JSON.stringify(e)}`)
      return defaultValue
    }
  }

  public hasSync(key: string): boolean {
    if (!this.dataPreferences) {
      Logger.info(TAG, `PreferenceUtil: dataPreferences is null`)
      return false
    }
    return this.dataPreferences?.hasSync(key)
  }

  public getAllSync(): object | null {
    if (!this.dataPreferences) {
      Logger.info(TAG, `PreferenceUtil: dataPreferences is null`)
      return null
    }
    return this.dataPreferences.getAllSync()
  }

  public delete(key: string):void {
    if (!this.dataPreferences) {
      Logger.info(TAG, `PreferenceUtil: dataPreferences is null`)
      return;
    }
    try {
      // 删除
      this.dataPreferences?.deleteSync(key)
      this.dataPreferences?.flush()
      Logger.info(TAG, '删除Preferences[${key} = ${value}]成功');
    } catch (e) {
      Logger.info(TAG, '删除Preferences[${key} = ${value}]失败' + JSON.stringify(e));
    }
  }

  isClean(): boolean {
    if (!this.dataPreferences) {
      Logger.info(TAG, `PreferenceUtil: dataPreferences is null`)
      return true
    }
    let arr: [] = [];
    let value = this.dataPreferences.getAllSync()
    if (value) {
      arr = Object.values(value) as [];
    }
    if (arr.length === 0) {
      return true
    }
    return false
  }

  clear():void {
    if (!this.dataPreferences) {
      Logger.info(TAG, `PreferenceUtil: dataPreferences is null`)
      return;
    }
    try {
      this.dataPreferences.clearSync()
      this.dataPreferences?.flush()
    } catch (e) {
      console.log('testTag', 'clear失败' + JSON.stringify(e));
    }
  }
}

