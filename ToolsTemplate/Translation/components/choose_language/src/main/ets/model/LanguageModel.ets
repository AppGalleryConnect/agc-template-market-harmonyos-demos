// 语言项接口
export interface Language {
  code: string; // 语言代码
  name: string; // 显示名称
  isVip: boolean; // 是否需要VIP会员
}

// 语言类型枚举
export enum LanguageType {
  SOURCE = 'source', // 源语言
  TARGET = 'target'  // 目标语言
}

// 预定义语言列表
export const LANGUAGE_LIST: Language[] = [
  { code: 'auto', name: '自动检测', isVip: false },
  { code: 'zh-CN', name: '中文', isVip: false },
  { code: 'en-US', name: '英文', isVip: false },
  { code: 'ja-JP', name: '日文', isVip: false },
  { code: 'fr-FR', name: '法文', isVip: false },
  { code: 'de-DE', name: '德文', isVip: false },
  { code: 'ko-KR', name: '韩文', isVip: true },
  { code: 'es-ES', name: '西班牙文', isVip: true },
  { code: 'ru-RU', name: '俄文', isVip: true },
  { code: 'pt-PT', name: '葡萄牙文', isVip: true },
  { code: 'it-IT', name: '意大利文', isVip: true },
  { code: 'ar-SA', name: '阿拉伯文', isVip: true },
  { code: 'th-TH', name: '泰文', isVip: true },
  { code: 'vi-VN', name: '越南文', isVip: true },
];

// 常用语言列表
export const COMMON_LANGUAGES: string[] = ['zh-CN', 'en-US', 'ko-KR', 'ja-JP'];
