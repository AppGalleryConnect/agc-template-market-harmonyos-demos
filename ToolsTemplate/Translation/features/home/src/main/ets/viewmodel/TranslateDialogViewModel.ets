import { promptAction } from '@kit.ArkUI'
import { TranslationConfig, TranslationFactory, TranslationResult, TranslationType } from 'baidu_translate';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import {
  LanguageType,
  TranslateHistoryItem,
  TranslateRequest,
  TranslateResponse,
} from '../model/TranslateDialogModel'
import { TranslateHomeViewModel } from './TranslateHomeViewModel'
import { LanguageCodeConverter } from '../utils/LanguageCodeConverter'

interface LanguageRegexMapping {
  regex: RegExp;
  code: string;
}

/**
 * 翻译对话页面ViewModel
 */
@ObservedV2
export class TranslateDialogViewModel {
  @Trace sourceLanguage: string = LanguageType.AUTO_DETECT
  @Trace targetLanguage: string = LanguageType.CHINESE
  @Trace inputText: string = ''
  @Trace detectedLanguage: string = ''
  @Trace historyList: TranslateHistoryItem[] = []
  private homeVm: TranslateHomeViewModel = TranslateHomeViewModel.instance
  // 百度翻译配置
  private static readonly APP_ID = '' // TODO: 替换为真实的 APP_ID
  private static readonly SECRET_KEY = '' // TODO: 替换为真实的 SECRET_KEY

  constructor() {
    // 异步加载历史记录
    this.loadHistoryFromCache().catch(() => {
    })
  }

  //从缓存加载历史记录
  private async loadHistoryFromCache(): Promise<void> {
    try {
      const context = getContext() as common.UIAbilityContext;
      const dataPreferences = await preferences.getPreferences(context, 'translate_data');
      const historyData = await dataPreferences.get('translate_history', '[]') as string;

      if (historyData && historyData !== '[]') {
        const parsedHistory = JSON.parse(historyData) as TranslateHistoryItem[]
        this.historyList = Array.isArray(parsedHistory) ? parsedHistory : []
      } else {
        this.historyList = []
      }
    } catch (error) {
      this.historyList = []
    }
  }

  //切换源语言和目标语言
  switchLanguages(): void {
    const temp = this.sourceLanguage
    this.sourceLanguage = this.targetLanguage
    this.targetLanguage = temp
    promptAction.showToast({ message: '已切换语言' })
  }

  //选择源语言
  selectSourceLanguage(language: string): void {
    this.sourceLanguage = language
    promptAction.showToast({ message: `源语言: ${language}` })
  }

  //选择目标语言
  selectTargetLanguage(language: string): void {
    this.targetLanguage = language
    promptAction.showToast({ message: `目标语言: ${language}` })
  }

  //选择历史记录项 - 跳转到详情页
  selectHistoryItem(_item: TranslateHistoryItem): void {
  }

  //清空历史记录
  clearHistory(): void {
    this.historyList = []
    this.saveHistoryToCache().catch(() => {
    })
    promptAction.showToast({ message: '已清空历史记录' })
  }

  //删除单条历史记录
  deleteHistoryItem(id: string): void {
    this.historyList = this.historyList.filter(item => item.id !== id)
    this.saveHistoryToCache().catch(() => {
    })
    promptAction.showToast({ message: '已删除' })
  }

  //自动检测输入文本的语言
  detectLanguage(text: string): void {
    const normalized = text.trim()
    if (normalized.length === 0) {
      this.detectedLanguage = ''
      this.homeVm.languageViewModel.setDetectedSourceLanguageByCode(null)
      return
    }

    const detectedCode = this.detectLanguageCode(normalized)
    if (detectedCode) {
      this.homeVm.languageViewModel.setDetectedSourceLanguageByCode(detectedCode)
      this.detectedLanguage = this.homeVm.languageViewModel.sourceLanguageDisplay.name
    } else {
      this.homeVm.languageViewModel.setDetectedSourceLanguageByCode(null)
      this.detectedLanguage = '未知'
    }
  }

  //根据文本内容返回语言代码
  private detectLanguageCode(text: string): string | null {
    const mapping: Array<LanguageRegexMapping> = [
      { regex: /[\u4e00-\u9fa5]/, code: 'zh-CN' },
      { regex: /[\u3040-\u309f\u30a0-\u30ff]/, code: 'ja-JP' },
      { regex: /[\uac00-\ud7af]/, code: 'ko-KR' },
      { regex: /[\u0600-\u06ff]/, code: 'ar-SA' },
      { regex: /[\u0400-\u04ff]/, code: 'ru-RU' },
      { regex: /[a-zA-Z]/, code: 'en-US' }
    ]

    for (const item of mapping) {
      if (item.regex.test(text)) {
        return item.code
      }
    }
    return null
  }

  //执行翻译
  async translate(showToast: boolean = true): Promise<TranslateResponse | null> {
    if (this.inputText.trim().length === 0) {
      promptAction.showToast({ message: '请输入要翻译的内容' })
      return null
    }

    // 优先使用已设置的语言（如语音输入设置的目标语言）
    // 如果是默认值，则使用homeVm的语言设置
    let sourceLanguageCode: string
    let targetLanguageCode: string

    if (this.sourceLanguage === LanguageType.AUTO_DETECT) {
      sourceLanguageCode = this.homeVm.languageViewModel.sourceLanguage.code
    } else {
      sourceLanguageCode = this.sourceLanguage
    }

    if (this.targetLanguage === LanguageType.CHINESE) {
      targetLanguageCode = this.homeVm.languageViewModel.targetLanguage.code
    } else {
      targetLanguageCode = this.targetLanguage
    }

    // 如果源语言不是"自动检测"，检查输入文本语言是否匹配
    if (sourceLanguageCode !== 'auto') {
      const detectedCode = this.detectLanguageCode(this.inputText.trim())
      const sourceBaiduCode = LanguageCodeConverter.toBaiduCode(sourceLanguageCode)

      // 检测到的语言与选择的源语言不一致时，自动使用"自动检测"
      if (detectedCode) {
        const detectedBaiduCode = LanguageCodeConverter.toBaiduCode(detectedCode)
        if (detectedBaiduCode !== sourceBaiduCode) {
          // 自动切换到自动检测模式
          sourceLanguageCode = 'auto'
        }
      }
    }

    const request: TranslateRequest = {
      sourceLanguage: sourceLanguageCode,
      targetLanguage: targetLanguageCode,
      text: this.inputText
    }

    try {
      const response = await this.performTranslate(request)
      if (response.success) {
        // 添加到历史记录，保存翻译结果
        this.addToHistory(this.inputText, response.result, response.sourceLanguage, response.targetLanguage)
        if (showToast) {
          promptAction.showToast({ message: '翻译成功' })
        }
        // 清空输入框
        this.inputText = ''
        // 清空检测到的语言
        this.detectedLanguage = ''
        return response
      } else {
        promptAction.showToast({ message: response.errorMessage || '翻译失败' })
        return null
      }
    } catch (error) {
      promptAction.showToast({ message: '翻译出错' })
      return null
    }
  }

  //执行翻译请求
  private async performTranslate(request: TranslateRequest): Promise<TranslateResponse> {
    try {
      // 使用工具类将语言代码转换为百度翻译API支持的格式
      const fromLang = LanguageCodeConverter.toBaiduCode(request.sourceLanguage)
      const toLang = LanguageCodeConverter.toBaiduCode(request.targetLanguage)

      // 初始化翻译配置
      const config: TranslationConfig = {
        appId: TranslateDialogViewModel.APP_ID,
        secretKey: TranslateDialogViewModel.SECRET_KEY
      };

      // 获取翻译服务实例
      const service = TranslationFactory.getTranslationService(config, TranslationType.BAIDU);

      // 调用翻译API
      const result = await service.translate({
        query: request.text,
        from: fromLang,
        to: toLang
      });

      // 提取翻译结果
      const resultList = result.transResult || [];
      const translatedText = resultList.map((item: TranslationResult) => item.dst).join('\n')

      // 使用 API 返回的实际检测到的源语言
      const detectedSourceLang = result.from || request.sourceLanguage;


      return {
        result: translatedText,
        sourceLanguage: detectedSourceLang,
        targetLanguage: request.targetLanguage,
        success: true,
      }
    } catch (error) {
      return {
        result: '',
        sourceLanguage: request.sourceLanguage,
        targetLanguage: request.targetLanguage,
        success: false,
        errorMessage: '翻译服务异常，请稍后重试'
      }
    }
  }


  //添加到历史记录
  private addToHistory(text: string, translatedText: string, sourceLanguage: string, targetLanguage: string): void {
    const newItem: TranslateHistoryItem = {
      id: Date.now().toString(),
      text: text,
      translatedText: translatedText,
      languagePair: LanguageCodeConverter.getLanguagePairLabel(sourceLanguage, targetLanguage),
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      timestamp: Date.now()
    }
    this.historyList.unshift(newItem)

    // 限制历史记录数量
    if (this.historyList.length > 50) {
      this.historyList = this.historyList.slice(0, 50)
    }

    // 保存到本地存储
    this.saveHistoryToCache().catch(() => {
    })
  }

  //保存历史记录到本地存储
  private async saveHistoryToCache(): Promise<void> {
    try {
      const historyData = JSON.stringify(this.historyList)
      const context = getContext() as common.UIAbilityContext;
      const dataPreferences = await preferences.getPreferences(context, 'translate_data');
      await dataPreferences.put('translate_history', historyData);
      await dataPreferences.flush();
    } catch (error) {
    }
  }
}
