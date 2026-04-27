/**
 * 语音翻译辅助工具类
 * 处理语音输入后的翻译逻辑
 */
import { promptAction } from '@kit.ArkUI';
import { TranslateDialogViewModel } from '../viewmodel/TranslateDialogViewModel';
import { TranslateDetailViewModel } from '../viewmodel/TranslateDetailViewModel';
import { LanguageCodeMapper } from './LanguageCodeMapper';

export class VoiceTranslateHelper {
  /**
   * 处理语音输入完成后的翻译流程
   * @param voiceText 语音识别的文本
   * @param targetLangCode 目标语言代码（从语音输入页面选择）
   * @returns 翻译是否成功
   */
  static async handleVoiceTranslate(
    voiceText: string,
    targetLangCode: string,
  ): Promise<boolean> {
    // 1. 使用TranslateDialogViewModel进行真实翻译
    const dialogVm = new TranslateDialogViewModel();
    dialogVm.inputText = voiceText;

    // 设置目标语言为语音输入页面选择的语言
    dialogVm.targetLanguage = targetLangCode;

    // 显示加载提示
    promptAction.showToast({ message: '正在翻译...' });

    const response = await dialogVm.translate();

    if (response && response.success) {
      // 2. 获取检测到的源语言显示名称
      const detectedLanguageName = LanguageCodeMapper.toDisplayName(response.sourceLanguage);
      const targetLanguageName = LanguageCodeMapper.toDisplayName(targetLangCode);


      // 3. 准备数据
      TranslateDetailViewModel.instance.updateDetail({
        sourceLanguageName: response.sourceLanguage,
        targetLanguageName: targetLangCode,
        sourceLanguageDisplayName: detectedLanguageName,
        targetLanguageDisplayName: targetLanguageName,
        detectedLanguageHint: '',
        sourceText: voiceText,
        translatedText: response.result,
        imageBuffer: undefined
      });

      return true;
    }

    return false;
  }
}
