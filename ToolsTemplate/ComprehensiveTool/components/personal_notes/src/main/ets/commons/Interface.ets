import { ShowMethod, SortEnum, ToolBarName } from './Enum';

export interface ToolBar {
  name: ToolBarName,
  icon: Resource
}

export interface NoteOperateType {
  name: ResourceStr
  type: ShowMethod | SortEnum
}

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