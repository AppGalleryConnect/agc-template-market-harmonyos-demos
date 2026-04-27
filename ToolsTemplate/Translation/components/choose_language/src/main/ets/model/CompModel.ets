// 组件参数接口定义

import { Language } from './LanguageModel';

export interface VipUpgradeDialogParams {
  visible: boolean; // 是否显示
  onClose?: () => void; // 关闭回调
  onUpgrade?: () => void; // 升级回调
}

export interface LanguageListItemParams {
  language: Language; // 语言数据
  isSelected: boolean; // 是否选中
  onSelect?: (language: Language) => void; // 选择回调
}
