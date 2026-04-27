import { Language } from '../model/language'

export const commonLanguages: Language[] = [{ text: '中文', code: 'cn' }, { text: '英文', code: 'en' }]

export const allLanguages: Language[] = [
  { text: '中文', code: 'zh' },
  { text: '英文', code: 'en' },
  { text: '日语', code: 'ja' },
  { text: '俄语', code: 'ru' },
  { text: '法语', code: 'fr' },
  { text: '西班牙语', code: 'es' },
  { text: '阿拉伯语', code: 'ar' },
  { text: '德语', code: 'de' },
  { text: '泰语', code: 'th' },
  { text: '越南语', code: 'vi' },
  { text: '印地语', code: 'hi' },
  { text: '葡萄牙语', code: 'pt' },
  { text: '意大利语', code: 'it' },
  { text: '马来语', code: 'ms' },
  { text: '印尼语', code: 'id' },
  { text: '土耳其语', code: 'tr' },
  { text: '希腊语', code: 'el' },
  { text: '捷克语', code: 'cs' },
]

// 录制状态
export enum RecordStatus {
  //  等待录制
  PENDING = '0',
  //  进行中
  PROGRESS = '1',
  //  结束
  OFF = '2'
}

// websocket发送的消息的状态
export const STATUS_FIRST_FRAME = 0;

export const STATUS_CONTINUE_FRAME = 1;

export const STATUS_LAST_FRAME = 2;

export const BUFFER_SIZE = 1280

export const INTERVAL_TIME = 0.04