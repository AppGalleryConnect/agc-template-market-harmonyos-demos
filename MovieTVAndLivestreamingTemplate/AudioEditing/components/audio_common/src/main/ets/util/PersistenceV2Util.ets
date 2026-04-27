import { PersistenceV2 } from '@kit.ArkUI';
import { buffer, util } from '@kit.ArkTS';
import { preferences } from '@kit.ArkData';
import { CommonContext } from './CommonContext';

@ObservedV2
export class MusicPersistence {
  @Trace data: string = ''
}

@ObservedV2
export class WorkPersistence {
  @Trace data: string = ''
}

@ObservedV2
export class HistoryPersistence {
  @Trace data: string = ''
}

/*
 * 此类不能使用静态函数，否则不能正常拿到本地数据
 */
export class PersistenceV2Util {
  static dataPreferences: preferences.Preferences | undefined = undefined

  static instance() {
    if (!PersistenceV2Util.dataPreferences) {
      PersistenceV2Util.dataPreferences =
        preferences.getPreferencesSync(CommonContext.getContext() as Context, { name: 'myStore' })
    }
    return PersistenceV2Util.dataPreferences
  }

  /*
   * 设置数据
   */
  setData(data: string, type: 'music' | 'work') {
    if (this.getStringSize(data) > 15 * 1024) {
      return false
    }
    const tempData = data.replace(/__ob_/g, '')
    let uInt8Array = new util.TextEncoder().encodeInto(tempData);
    PersistenceV2Util.instance().putSync(type, uInt8Array);
    PersistenceV2Util.instance().flushSync()
    return true
  }

  /*
   * 获取数据
   */
  getData(type: 'music' | 'work'): string {
    let uInt8Array: preferences.ValueType = PersistenceV2Util.instance().getSync(type, new Uint8Array(0));
    let textDecoder = util.TextDecoder.create('utf-8');
    let val = textDecoder.decodeToString(uInt8Array as Uint8Array);
    return val
  }

  /*
   * 设置历史记录
   */
  setHistory(data: string) {
    if (this.getStringSize(data) > 15 * 1024) {
      return false
    }
    if (data) {
      let uInt8Array = new util.TextEncoder().encodeInto(data);
      PersistenceV2Util.instance().putSync('history', uInt8Array);
    } else {
      PersistenceV2Util.instance().putSync('history', '');
    }

    PersistenceV2Util.instance().flushSync()
    return true
  }

  /*
   * 获取历史记录
   */
  getHistory() {
    let uInt8Array: preferences.ValueType = PersistenceV2Util.instance().getSync('history', new Uint8Array(0));
    let textDecoder = util.TextDecoder.create('utf-8');
    let val = textDecoder.decodeToString(uInt8Array as Uint8Array);
    return val
  }

  /*
   * 获取字符串占用字节大小
   */
  getStringSize(content: string) {
    try {
      return buffer.from(content, 'utf-8').buffer.byteLength
    } catch (err) {
      return 0
    }
  }
}

