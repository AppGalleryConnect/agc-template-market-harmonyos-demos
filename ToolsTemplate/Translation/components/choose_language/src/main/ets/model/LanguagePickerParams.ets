// 语言选择器参数接口定义

import { Language } from './LanguageModel';
import { LanguageViewModel } from '../viewmodel/LanguageViewModel';

/**
 * 语言选择器页面参数接口
 */
export interface LanguagePickerParams {
  viewModel: LanguageViewModel;
  onLanguageSelected?: (language: Language) => void;
  onClose?: () => void;
}
