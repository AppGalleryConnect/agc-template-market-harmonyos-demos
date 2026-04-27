export enum ToolBarName {
  move_category = '移动到分类',
  delete = '删除',
  select_all = '全选'
}

export enum ShowMethod {
  waterFlowList = '1',  // 瀑布流方式展示
  normalList = '2'      // 常规列表
}

/**
 * 排序方式
 */
export enum SortEnum {
  /**
   * 按创建时间
   */
  CREATE_TIME = 'createTime',
  /**
   * 按修改时间
   */
  UPDATE_TIME = 'updateTime',
  /**
   * 按进入回收站时间升序（最早在前）
   */
  CREATE_TIME_ASC = 'createTimeAsc',

  /**
   * 按进入回收站时间降序（最晚在前）
   */
  CREATE_TIME_DESC = 'createTimeDesc',
}

/**
 * 段落对齐样式
 *
 */
export enum TextAlignment {
  START = 0,
  CENTER,
  END,
  JUSTIFY
}