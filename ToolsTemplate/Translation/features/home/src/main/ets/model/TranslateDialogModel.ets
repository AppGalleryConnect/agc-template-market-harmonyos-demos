/**
 * 语言类型枚举
 */
export enum LanguageType {
  AUTO_DETECT = '自动检测',
  CHINESE = '中文',
  ENGLISH = '英语',
  JAPANESE = '日语',
  KOREAN = '韩语',
  FRENCH = '法语',
  GERMAN = '德语',
  SPANISH = '西班牙语',
  RUSSIAN = '俄语',
  ARABIC = '阿拉伯语'
}

/**
 * 翻译对话历史项接口
 */
export interface TranslateHistoryItem {
  //唯一标识
  id: string
  //源文本
  text: string
  //翻译结果
  translatedText: string
  //语言对显示
  languagePair: string
  //源语言代码
  sourceLanguage: string
  //目标语言代码
  targetLanguage: string
  //创建时间
  timestamp: number
}

/**
 * 翻译请求接口
 */
export interface TranslateRequest {
  //源语言
  sourceLanguage: string
  //目标语言
  targetLanguage: string
  //待翻译文本
  text: string
}

/**
 * 翻译响应接口
 */
export interface TranslateResponse {
  //翻译结果
  result: string
  //源语言
  sourceLanguage: string
  //目标语言
  targetLanguage: string
  //是否成功
  success: boolean
  //错误信息
  errorMessage?: string
}

