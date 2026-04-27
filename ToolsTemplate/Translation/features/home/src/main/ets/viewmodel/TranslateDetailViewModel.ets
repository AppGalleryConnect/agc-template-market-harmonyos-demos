export interface TranslateDetailData {
  sourceLanguageName: string
  targetLanguageName: string
  sourceLanguageDisplayName?: string
  targetLanguageDisplayName?: string
  detectedLanguageHint?: string
  sourceText: string
  translatedText: string
  imageBuffer?: ArrayBuffer
  imagePath?: string
  sourceLanguageCode?: string
  targetLanguageCode?: string
}

@ObservedV2
export class TranslateDetailViewModel {
  private static _instance: TranslateDetailViewModel
  @Trace sourceLanguageName: string = '自动检测'
  @Trace targetLanguageName: string = '中文'
  @Trace sourceLanguageDisplayName: string = '自动检测'
  @Trace targetLanguageDisplayName: string = '中文'
  @Trace detectedLanguageHint: string = ''
  @Trace sourceText: string = ''
  @Trace translatedText: string = ''
  @Trace imageBuffer: ArrayBuffer | null = null
  @Trace imagePath: string = ''
  @Trace sourceLanguageCode: string = ''
  @Trace targetLanguageCode: string = ''
  // 重新翻译的回调函数
  onRetranslate: ((sourceLang: string, targetLang: string) => Promise<void>) | null = null

  static get instance(): TranslateDetailViewModel {
    if (!TranslateDetailViewModel._instance) {
      TranslateDetailViewModel._instance = new TranslateDetailViewModel()
    }
    return TranslateDetailViewModel._instance
  }

  private constructor() {
  }

  updateDetail(data: TranslateDetailData): void {
    this.sourceLanguageName = data.sourceLanguageName
    this.targetLanguageName = data.targetLanguageName
    this.sourceLanguageDisplayName = data.sourceLanguageDisplayName ?? data.sourceLanguageName
    this.targetLanguageDisplayName = data.targetLanguageDisplayName ?? data.targetLanguageName
    this.detectedLanguageHint = data.detectedLanguageHint ?? ''
    this.sourceText = data.sourceText
    this.translatedText = data.translatedText
    // 更新图片翻译相关数据
    this.imageBuffer = data.imageBuffer ?? null
    this.imagePath = data.imagePath ?? ''
    this.sourceLanguageCode = data.sourceLanguageCode ?? ''
    this.targetLanguageCode = data.targetLanguageCode ?? ''
  }

  reset(): void {
    this.sourceLanguageName = '自动检测'
    this.targetLanguageName = '中文'
    this.sourceLanguageDisplayName = '自动检测'
    this.targetLanguageDisplayName = '中文'
    this.detectedLanguageHint = ''
    this.sourceText = ''
    this.translatedText = ''
    this.imageBuffer = null
    this.imagePath = ''
    this.sourceLanguageCode = ''
    this.targetLanguageCode = ''
    this.onRetranslate = null
  }

  clearSourceText(): void {
    this.sourceText = ''
  }

  /**
   * 切换源语言和目标语言
   */
  async switchLanguages(): Promise<void> {
    // 交换语言名称
    const tempName = this.sourceLanguageName
    this.sourceLanguageName = this.targetLanguageName
    this.targetLanguageName = tempName

    const tempDisplayName = this.sourceLanguageDisplayName
    this.sourceLanguageDisplayName = this.targetLanguageDisplayName
    this.targetLanguageDisplayName = tempDisplayName

    // 交换语言代码
    const tempCode = this.sourceLanguageCode
    this.sourceLanguageCode = this.targetLanguageCode
    this.targetLanguageCode = tempCode

    // 交换文本
    const tempText = this.sourceText
    this.sourceText = this.translatedText
    this.translatedText = tempText

    // 图片翻译时不需要重新调用API，直接交换文本即可
    // 只有非图片翻译才需要重新翻译
    if (!this.imageBuffer && this.onRetranslate) {
      await this.onRetranslate(this.sourceLanguageCode, this.targetLanguageCode)
    }
  }
}

