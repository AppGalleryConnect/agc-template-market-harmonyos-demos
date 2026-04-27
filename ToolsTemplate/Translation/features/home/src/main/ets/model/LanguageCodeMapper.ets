/**
 * 语言代码映射工具类
 * 用于将语言代码转换为显示名称
 */
export class LanguageCodeMapper {
  private static readonly LANGUAGE_MAP: Record<string, string> = {
    'zh': '中文',
    'zh-CN': '中文',
    'zh-Hans': '中文',
    'en': '英文',
    'en-US': '英文',
    'en-GB': '英文',
    'jp': '日文',
    'ja': '日文',
    'ja-JP': '日文',
    'ko': '韩文',
    'ko-KR': '韩文',
    'kor': '韩文',
    'fr': '法文',
    'fr-FR': '法文',
    'fra': '法文',
    'de': '德文',
    'de-DE': '德文',
    'es': '西班牙文',
    'es-ES': '西班牙文',
    'spa': '西班牙文',
    'ru': '俄文',
    'ru-RU': '俄文',
    'ara': '阿拉伯文',
    'ar': '阿拉伯文',
    'ar-SA': '阿拉伯文',
    'th': '泰文',
    'th-TH': '泰文',
    'vi': '越南文',
    'vi-VN': '越南文',
    'vie': '越南文',
    'pt': '葡萄牙文',
    'pt-PT': '葡萄牙文',
    'pt-BR': '葡萄牙文',
    'it': '意大利文',
    'it-IT': '意大利文',
    'auto': '自动检测'
  };

  /**
   * 将语言代码转换为显示名称
   * @param code 语言代码
   * @returns 显示名称
   */
  static toDisplayName(code: string): string {
    return LanguageCodeMapper.LANGUAGE_MAP[code] || code;
  }
}
