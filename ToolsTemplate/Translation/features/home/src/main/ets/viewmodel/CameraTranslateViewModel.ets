/**
 * 拍照翻译ViewModel
 */
import {
  BaiduImageTranslation,
  ImageTranslationParam,
  ImageTranslationResponse,
  TranslationConfig
} from 'baidu_translate';

@ObservedV2
export class CameraTranslateViewModel {
  // 原始图片路径
  @Trace originalImagePath: string = '';
  // 翻译后的图片数据
  @Trace translatedImageData: string = '';
  // 识别的文本
  @Trace recognizedText: string = '';
  // 翻译后的文本
  @Trace translatedText: string = '';
  // 加载状态
  @Trace isLoading: boolean = false;
  // 错误信息
  @Trace errorMessage: string = '';
  // 检测到的源语言
  @Trace detectedSourceLanguage: string = '';
  // 实际使用的目标语言
  @Trace actualTargetLanguage: string = '';


  // 百度翻译配置
  private static readonly APP_ID = ''; // TODO: 替换为真实的 APP_ID
  private static readonly SECRET_KEY = ''; // TODO: 替换为真实的 SECRET_KEY

  /**
   * 检测文本是否主要是中文
   */
  private isChineseText(text: string): boolean {
    if (!text) {
      return false;
    }
    // 匹配中文字符（包括常用汉字）
    const chineseRegex = /[\u4e00-\u9fa5]/g;
    const chineseMatches = text.match(chineseRegex);
    const chineseCount = chineseMatches ? chineseMatches.length : 0;
    // 如果中文字符占比超过30%，认为是中文
    return chineseCount / text.length > 0.3;
  }

  /**
   * 检测文本是否主要是英文
   */
  private isEnglishText(text: string): boolean {
    if (!text) {
      return false;
    }
    // 匹配英文字母
    const englishRegex = /[a-zA-Z]/g;
    const englishMatches = text.match(englishRegex);
    const englishCount = englishMatches ? englishMatches.length : 0;
    // 如果英文字母占比超过30%，认为是英文
    return englishCount / text.length > 0.3;
  }

  private isSupportedLanguage(text: string): boolean {
    return this.isChineseText(text) || this.isEnglishText(text);
  }

  //翻译图片
  async translateImage(imageData: ArrayBuffer, imagePath: string, from: string, to: string): Promise<boolean> {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      // 创建翻译配置
      const config: TranslationConfig = {
        appId: CameraTranslateViewModel.APP_ID,
        secretKey: CameraTranslateViewModel.SECRET_KEY
      };

      // 创建图片翻译服务
      const imageTranslation = new BaiduImageTranslation(config);

      let actualTo = to;
      if (from === 'auto' && to === 'auto') {
        actualTo = 'zh'; // 默认翻译成中文
      }

      // 构建请求参数
      const param: ImageTranslationParam = {
        imageData: imageData,
        imagePath: imagePath,
        from: from,
        to: actualTo,
        paste: 1,
        needIntervene: 0
      };

      // 调用翻译API
      const response: ImageTranslationResponse = await imageTranslation.translateImage(param);

      this.isLoading = false;

      if (response.data) {
        // 获取识别和翻译的文本
        const srcText = response.data.sumSrc || '';
        const dstText = response.data.sumDst || '';

        // 智能中英互译：如果源文本和目标文本相同，说明没有翻译（源语言=目标语言）
        const needRetry = from === 'auto' && to === 'auto' && srcText === dstText && srcText.length > 0;

        if (needRetry) {
          // 源文本和目标文本相同，说明源语言就是目标语言
          this.detectedSourceLanguage = actualTo;

          // 根据目标语言切换：如果目标是中文，切换到英文；否则切换到中文
          const newTarget = actualTo === 'zh' ? 'en' : 'zh';

          // 重新调用API，使用auto作为源语言，新的目标语言
          const retryParam: ImageTranslationParam = {
            imageData: imageData,
            imagePath: imagePath,
            from: 'auto',
            to: newTarget,
            paste: 1,
            needIntervene: 0
          };

          this.isLoading = true; // 重新设置加载状态
          const retryResponse = await imageTranslation.translateImage(retryParam);
          this.isLoading = false;

          if (retryResponse.data) {
            this.translatedImageData = retryResponse.data.image || retryResponse.data.pasteImg || '';
            this.recognizedText = retryResponse.data.sumSrc || '';
            this.translatedText = retryResponse.data.sumDst || '';
            this.actualTargetLanguage = newTarget; // 保存实际使用的目标语言
            return true;
          } else {
            this.errorMessage = retryResponse.errorMsg || '重新翻译失败';
            return false;
          }
        }

        this.translatedImageData = response.data.image || response.data.pasteImg || '';
        this.recognizedText = response.data.sumSrc || '';
        this.translatedText = response.data.sumDst || '';
        this.actualTargetLanguage = actualTo; // 保存实际使用的目标语言

        // 检查识别的文本是否是支持的语言（中文或英文）
        if (!this.isSupportedLanguage(this.recognizedText)) {
          this.errorMessage = '拍照翻译仅支持中英文，请拍摄中文或英文文本';
          return false;
        }

        // 推断源语言
        this.detectedSourceLanguage = actualTo === 'zh' ? 'en' : 'zh';
        return true;
      }  else {
        this.errorMessage = response.errorMsg || '翻译失败';
        return false;
      }
    } catch (error) {
      this.isLoading = false;
      this.errorMessage = (error as Error).message || '翻译异常';
      return false;
    }
  }

  //重置状态
  reset(): void {
    this.originalImagePath = '';
    this.translatedImageData = '';
    this.recognizedText = '';
    this.translatedText = '';
    this.isLoading = false;
    this.errorMessage = '';
    this.detectedSourceLanguage = '';
    this.actualTargetLanguage = '';
  }
}
