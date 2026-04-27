import { TextReaderController, ReaderContent, TextParams } from 'text_reader'
import { promptAction } from '@kit.ArkUI'

// 不支持朗读的语言代码列表
const UNSUPPORTED_LANGUAGES: string[] = [
  'kor', 'ko-KR', 'ko',           // 韩文
  'ru', 'ru-RU',                   // 俄文
  'ara', 'ar-SA', 'ar',            // 阿拉伯文
  'th', 'th-TH',                   // 泰文
  'vie', 'vi-VN', 'vi'             // 越南文
]

// 语言代码到显示名称的映射
const LANGUAGE_NAMES: Record<string, string> = {
  'kor': '韩文', 'ko-KR': '韩文', 'ko': '韩文',
  'ru': '俄文', 'ru-RU': '俄文',
  'ara': '阿拉伯文', 'ar-SA': '阿拉伯文', 'ar': '阿拉伯文',
  'th': '泰文', 'th-TH': '泰文',
  'vie': '越南文', 'vi-VN': '越南文', 'vi': '越南文'
}

/**
 * 文本朗读助手类
 */
export class TranslateTextReader {
  /**
   * 检查语言是否支持朗读
   * @param languageCode 语言代码
   * @returns true 表示支持，false 表示不支持
   */
  static isSupportedLanguage(languageCode: string): boolean {
    return !UNSUPPORTED_LANGUAGES.includes(languageCode)
  }

  /**
   * 获取不支持语言的提示信息
   * @param languageCode 语言代码
   * @returns 提示信息
   */
  static getUnsupportedMessage(languageCode: string): string {
    const langName = LANGUAGE_NAMES[languageCode] || '该语言'
    return `${langName}暂不支持朗读`
  }

  static async playText(controller: TextReaderController, text: string, title: string,
    id: string = 'text', languageCode?: string): Promise<boolean> {
    if (!text || text.length === 0) {
      return false
    }

    // 检查语言是否支持朗读
    if (languageCode && !TranslateTextReader.isSupportedLanguage(languageCode)) {
      promptAction.showToast({
        message: TranslateTextReader.getUnsupportedMessage(languageCode),
        duration: 2000
      })
      return false
    }

    const readerContent: ReaderContent = {
      id: id,
      title: {
        text: title,
        isClickable: false
      } as TextParams,
      bodyInfo: text
    }

    try {
      await controller.textReaderStart([readerContent], id)
      // 播放后立即隐藏面板，只保留声音播放
      controller.textReaderHidePanel()
      return true
    } catch (error) {
      return false
    }
  }

  //停止朗读
  static async stop(controller: TextReaderController): Promise<void> {
    try {
      await controller.textReaderStop()
    } catch (error) {
    }
  }

  //暂停朗读
  static pause(controller: TextReaderController): void {
    controller.textReaderPause()
  }

  //继续朗读
  static resume(controller: TextReaderController): void {
    controller.textReaderResume()
  }

  //释放资源
  static async release(controller: TextReaderController): Promise<void> {
    try {
      await controller.textReaderRelease()
    } catch (error) {
    }
  }
}
