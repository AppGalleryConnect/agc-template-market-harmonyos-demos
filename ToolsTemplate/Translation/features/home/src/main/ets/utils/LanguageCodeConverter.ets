/**
 * 语言代码转换工具类
 * 统一管理所有语言代码的转换、规范化和显示逻辑
 */
export class LanguageCodeConverter {
  /**
   * 语言代码到百度翻译API代码的映射表
   */
  private static readonly BAIDU_CODE_MAP = new Map<string, string>([
    // 自动检测
    ['auto', 'auto'],
    ['自动检测', 'auto'],

    // 中文
    ['zh-CN', 'zh'],
    ['zh', 'zh'],
    ['中文', 'zh'],

    // 英文
    ['en-US', 'en'],
    ['en', 'en'],
    ['英文', 'en'],

    // 日文
    ['ja-JP', 'jp'],
    ['ja', 'jp'],
    ['日文', 'jp'],
    ['jp', 'jp'],

    // 韩文
    ['ko-KR', 'kor'],
    ['ko', 'kor'],
    ['韩文', 'kor'],
    ['kor', 'kor'],

    // 法文
    ['fr-FR', 'fra'],
    ['fr', 'fra'],
    ['法文', 'fra'],
    ['fra', 'fra'],

    // 德文
    ['de-DE', 'de'],
    ['de', 'de'],
    ['德文', 'de'],

    // 西班牙文
    ['es-ES', 'spa'],
    ['es', 'spa'],
    ['西班牙文', 'spa'],
    ['spa', 'spa'],

    // 俄文
    ['ru-RU', 'ru'],
    ['ru', 'ru'],
    ['俄文', 'ru'],

    // 阿拉伯文
    ['ar-SA', 'ara'],
    ['ar', 'ara'],
    ['阿拉伯文', 'ara'],
    ['ara', 'ara'],

    // 葡萄牙文
    ['pt-PT', 'pt'],
    ['pt', 'pt'],
    ['葡萄牙文', 'pt'],

    // 意大利文
    ['it-IT', 'it'],
    ['it', 'it'],
    ['意大利文', 'it'],

    // 泰文
    ['th-TH', 'th'],
    ['th', 'th'],
    ['泰文', 'th'],

    // 越南文
    ['vi-VN', 'vie'],
    ['vi', 'vie'],
    ['越南文', 'vie'],
    ['vie', 'vie']
  ]);
  /**
   * 语言代码到中文显示名称的映射表
   */
  private static readonly DISPLAY_NAME_MAP = new Map<string, string>([
    ['auto', '自动检测'],
    ['zh', '中文'],
    ['zh-CN', '中文'],
    ['en', '英文'],
    ['en-US', '英文'],
    ['ja', '日文'],
    ['ja-JP', '日文'],
    ['jp', '日文'],
    ['ko', '韩文'],
    ['ko-KR', '韩文'],
    ['kor', '韩文'],
    ['fr', '法文'],
    ['fr-FR', '法文'],
    ['fra', '法文'],
    ['de', '德文'],
    ['de-DE', '德文'],
    ['es', '西班牙文'],
    ['es-ES', '西班牙文'],
    ['spa', '西班牙文'],
    ['ru', '俄文'],
    ['ru-RU', '俄文'],
    ['ar', '阿拉伯文'],
    ['ar-SA', '阿拉伯文'],
    ['ara', '阿拉伯文'],
    ['pt', '葡萄牙文'],
    ['pt-PT', '葡萄牙文'],
    ['it', '意大利文'],
    ['it-IT', '意大利文'],
    ['th', '泰文'],
    ['th-TH', '泰文'],
    ['vi', '越南文'],
    ['vi-VN', '越南文'],
    ['vie', '越南文']
  ]);
  /**
   * 语言代码到简短标签的映射表（用于历史记录显示）
   */
  private static readonly SHORT_LABEL_MAP = new Map<string, string>([
    ['zh', '中'],
    ['zh-CN', '中'],
    ['en', '英'],
    ['en-US', '英'],
    ['ja', '日'],
    ['ja-JP', '日'],
    ['jp', '日'],
    ['ko', '韩'],
    ['ko-KR', '韩'],
    ['kor', '韩'],
    ['fr', '法'],
    ['fr-FR', '法'],
    ['fra', '法'],
    ['de', '德'],
    ['de-DE', '德'],
    ['es', '西'],
    ['es-ES', '西'],
    ['spa', '西'],
    ['ru', '俄'],
    ['ru-RU', '俄'],
    ['ar', '阿'],
    ['ar-SA', '阿'],
    ['ara', '阿'],
    ['pt', '葡'],
    ['pt-PT', '葡'],
    ['it', '意'],
    ['it-IT', '意'],
    ['th', '泰'],
    ['th-TH', '泰'],
    ['vi', '越'],
    ['vi-VN', '越'],
    ['vie', '越']
  ]);
  /**
   * 语言前缀到标准代码的映射表
   */
  private static readonly PREFIX_NORMALIZE_MAP = new Map<string, string>([
    ['zh', 'zh'],
    ['en', 'en'],
    ['ja', 'jp'],
    ['jp', 'jp'],
    ['ko', 'kor'],
    ['kor', 'kor'],
    ['fr', 'fra'],
    ['fra', 'fra'],
    ['de', 'de'],
    ['es', 'spa'],
    ['spa', 'spa'],
    ['ru', 'ru'],
    ['ar', 'ara'],
    ['ara', 'ara'],
    ['pt', 'pt'],
    ['it', 'it'],
    ['th', 'th'],
    ['vi', 'vie'],
    ['vie', 'vie'],
    ['auto', 'auto']
  ]);

  /**
   * 规范化语言代码
   * 将各种格式的语言代码统一为标准格式
   */
  static normalize(code: string): string {
    if (!code) {
      return 'auto';
    }

    const normalized = code.trim().toLowerCase();

    // 先尝试精确匹配
    const exactMatch = LanguageCodeConverter.PREFIX_NORMALIZE_MAP.get(normalized);
    if (exactMatch) {
      return exactMatch;
    }

    // 尝试前缀匹配
    return LanguageCodeConverter.normalizeByPrefix(normalized, code);
  }

  /**
   * 通过前缀匹配规范化语言代码
   */
  private static normalizeByPrefix(normalized: string, originalCode: string): string {
    const prefixes = ['zh', 'en', 'ja', 'ko', 'fr', 'de', 'es', 'ru', 'ar', 'pt', 'it', 'th', 'vi'];

    for (const prefix of prefixes) {
      if (normalized.startsWith(prefix)) {
        const result = LanguageCodeConverter.PREFIX_NORMALIZE_MAP.get(prefix);
        if (result) {
          return result;
        }
      }
    }

    return originalCode;
  }

  /**
   * 转换为百度翻译API支持的语言代码
   */
  static toBaiduCode(code: string): string {
    if (!code) {
      return 'auto';
    }

    const normalized = code.trim();
    const baiduCode = LanguageCodeConverter.BAIDU_CODE_MAP.get(normalized);

    if (baiduCode) {
      return baiduCode;
    }

    // 如果映射表中没有，尝试规范化后再查找
    const normalizedCode = LanguageCodeConverter.normalize(normalized);
    return LanguageCodeConverter.BAIDU_CODE_MAP.get(normalizedCode) ?? 'auto';
  }

  /**
   * 获取语言的中文显示名称
   */
  static toDisplayName(code: string): string {
    if (!code) {
      return '未知';
    }

    const normalized = code.trim();
    const displayName = LanguageCodeConverter.DISPLAY_NAME_MAP.get(normalized);

    if (displayName) {
      return displayName;
    }

    // 如果映射表中没有，返回原始代码
    return code;
  }

  /**
   * 获取语言的简短标签（用于历史记录等紧凑显示）
   */
  static getShortLabel(code: string): string {
    if (!code) {
      return '中';
    }

    const normalized = code.trim();
    const label = LanguageCodeConverter.SHORT_LABEL_MAP.get(normalized);

    if (label) {
      return label;
    }

    // 如果映射表中没有，返回第一个字符
    return code.substring(0, 1);
  }

  /**
   * 获取语言对的显示标签（如：中英、英中）
   */
  static getLanguagePairLabel(sourceCode: string, targetCode: string): string {
    const sourceLabel = LanguageCodeConverter.getShortLabel(sourceCode);
    const targetLabel = LanguageCodeConverter.getShortLabel(targetCode);
    return `${sourceLabel}${targetLabel}`;
  }

  /**
   * 检查语言代码是否为自动检测
   */
  static isAutoDetect(code: string): boolean {
    if (!code) {
      return false;
    }
    const normalized = code.trim().toLowerCase();
    return normalized === 'auto' || normalized === '自动检测';
  }

  /**
   * 验证语言代码是否有效
   */
  static isValidCode(code: string): boolean {
    if (!code) {
      return false;
    }
    const normalized = code.trim();
    return LanguageCodeConverter.BAIDU_CODE_MAP.has(normalized) ||
    LanguageCodeConverter.DISPLAY_NAME_MAP.has(normalized);
  }
}
