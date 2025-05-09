import dataPreferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common';

class PreferencesUtil {
  preMap: Map<string, dataPreferences.Preferences> = new Map()

  //创建Preferences实例
  async loadPreferences(context: common.UIAbilityContext, name: string) {
    try {
      let pref = await dataPreferences.getPreferences(context, name)
      this.preMap.set(name, pref)
    } catch (e) {
      // ...
    }
  }

  //写入数据
  async putPreferencesValue(name: string, key: string, value: dataPreferences.ValueType) {
    if (!this.preMap.has(name)) {

    }
    try {
      let pref = this.preMap.get(name) as dataPreferences.Preferences
      //写入数据
      await pref.put(key, value)
      //写入文件
      await pref.flush()
    } catch (e) {
      // ...
    }
  }

  //获取数据
  async getPreferencesValue(name: string, key: string,
    defValue: dataPreferences.ValueType): Promise<dataPreferences.ValueType | undefined> {
    if (!this.preMap.has(name)) {
      return undefined
    }
    try {
      let pref = this.preMap.get(name) as dataPreferences.Preferences
      //写入数据
      let value = await pref.get(key, defValue)
      return value
    } catch (e) {
      return undefined
    }
  }

  //判断是否包含key
  hasPreferenceskey(name: string, key: string): boolean | undefined {
    if (!this.preMap.has(name)) {
      return false
    }
    let pref = this.preMap.get(name) as dataPreferences.Preferences
    let isExist: boolean = pref.hasSync(key);
    return isExist
  }

  //删除指定key
  async deletePreferenceskey(name: string, key: string) {
    if (!this.preMap.has(name)) {
      return
    }
    let pref = this.preMap.get(name) as dataPreferences.Preferences
    //删除
    pref.deleteSync(key);
    //刷盘
    await pref.flush()
  }
}

export const preferencesUtil = new PreferencesUtil()