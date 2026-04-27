// 语言视图模型

import { Language, LANGUAGE_LIST, LanguageType } from '../model/LanguageModel';

// 语言选择视图模型
@ObservedV2
export class LanguageViewModel {
  // 源语言
  @Trace sourceLanguage: Language = { code: 'auto', name: '自动检测', isVip: false };

  // 目标语言
  @Trace targetLanguage: Language = { code: 'en', name: '英文', isVip: false };

  // 所有可用语言列表
  @Trace languageList: Language[] = LANGUAGE_LIST;

  // 用户VIP状态
  @Trace isVipUser: boolean = false;

  // 当前正在编辑的语言类型（源语言或目标语言）
  @Trace editingType: LanguageType = LanguageType.SOURCE;

  // 自动检测得到的源语言
  @Trace private detectedSourceLanguage: Language | null = null;

  // 根据VIP状态获取可用语言列表
  @Computed
  get availableLanguages(): Language[] {
    // 显示所有语言，包括VIP语言（会显示VIP图标）
    return this.languageList;
  }

  // 获取常用语言列表，用于快速访问
  @Computed
  get commonLanguages(): Language[] {
    return this.availableLanguages.slice(0, 4);
  }

  // 对外展示的源语言（优先展示自动检测结果）
  @Computed
  get sourceLanguageDisplay(): Language {
    return this.detectedSourceLanguage ?? this.sourceLanguage;
  }

  // 设置源语言
  setSourceLanguage(language: Language): void {
    // 防止目标语言设置为自动检测
    if (this.targetLanguage.code === 'auto' && language.code !== 'auto') {
      this.targetLanguage = this.getLanguageByCode('zh-CN')!;
    }
    this.sourceLanguage = language;
    if (language.code !== 'auto') {
      this.detectedSourceLanguage = null;
    }
  }

  // 设置目标语言
  setTargetLanguage(language: Language): void {
    // 目标语言不能是自动检测
    if (language.code === 'auto') {
      return;
    }
    this.targetLanguage = language;
  }

  // 交换源语言和目标语言
  swapLanguages(): void {
    // 如果源语言是自动检测，则不能交换
    if (this.sourceLanguage.code === 'auto') {
      return;
    }

    const temp = this.sourceLanguage;
    this.sourceLanguage = this.targetLanguage;
    this.targetLanguage = temp;
  }

  // 检查语言是否被锁定（需要VIP）
  isLanguageLocked(language: Language): boolean {
    return language.isVip && !this.isVipUser;
  }

  // 根据当前编辑类型选择语言
  selectLanguage(language: Language): void {
    if (this.isLanguageLocked(language)) {
      // 触发VIP升级提示
      return;
    }

    if (this.editingType === LanguageType.SOURCE) {
      this.setSourceLanguage(language);
    } else {
      this.setTargetLanguage(language);
    }
  }

  // 设置VIP状态
  setVipStatus(isVip: boolean): void {
    this.isVipUser = isVip;
  }

  // 设置编辑类型
  setEditingType(type: LanguageType): void {
    this.editingType = type;
  }

  // 根据语言代码获取语言对象
  private getLanguageByCode(code: string): Language | undefined {
    return this.languageList.find(lang => lang.code === code);
  }

  // 检查是否可以交换语言
  canSwap(): boolean {
    return this.sourceLanguage.code !== 'auto';
  }

  // 设置自动检测到的源语言
  setDetectedSourceLanguageByCode(code: string | null): void {
    if (!code) {
      this.detectedSourceLanguage = null;
      return;
    }

    const language = this.getLanguageByCode(code);
    if (language && language.code !== 'auto') {
      this.detectedSourceLanguage = language;
    } else {
      this.detectedSourceLanguage = null;
    }
  }
}
