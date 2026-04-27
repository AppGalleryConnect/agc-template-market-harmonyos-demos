import { ValueType } from '@kit.ArkData';
import { DBOperator } from './Enum';

/**
 * 编辑富文本框段落选项
 */
export interface AlignmentInfo {
  /**
   * 图标
   */
  icon: Resource;
  /**
   * 点击触发事件
   */
  click: VoidCallback;
}

// 图标+文本
export interface IconTextItem {
  // 图标
  icon: string;
  // 文案
  text: string;
}

export interface PrivacyPwdBuilderParams {
  confirm: (pwd?: string) => void
  cancel: () => void
}

export interface MoreFunction {
  name: ResourceStr
  icon?: ResourceStr,
  onClick: () => void
}

export type DateTimePickerResult = string | TimePickerResult;

export interface dateTimePickerBuilderParams {
  date: string
  change: (time: DateTimePickerResult) => void
}

// 表结构定义类型
export interface TableSchema {
  tableName: string;
  createSQL: string;
  indexes?: string[];
}

export interface DiaryTablePredicate {
  field: string;
  value: ValueType;
  operator: DBOperator;
}

export interface DiaryTableData {
  id: string,
  htmlContent: string,
  textContent: string,
  createTime: string,
  updateTime: string,
  yearMonth: string,
  weatherText: string,
  weatherIcon: string,
  moodText: string,
  moodIcon: string,
  firstImage: string,
  isPrivacy: boolean
}
