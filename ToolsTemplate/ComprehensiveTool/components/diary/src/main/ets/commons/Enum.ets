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

// 页面类型
export enum PageMode {
  CREATE = 0,
  VIEW,
  EDIT
}

export enum TEXT_PICKER_LABEL {
  weather = '选择天气',
  mood = '选择心情'
}

export enum DBOperator {
  EQUAL,
  NOT_EQUAL,
  GREATER,
  GREATER_OR_EQUAL,
  LESS,
  LESS_OR_EQUAL,
  LIKE,
  IS_NULL,
  IS_NOT_NULL,
  BEGIN_WITH,
  END_WITH,
  CONTAIN,
}

export enum DBOperationErrorCode {
  NO_STORE = -100,
  INSERT_ERROR = -101,
  UPDATE_ERROR = -102,
  DELETE_ERROR = -103,
  QUERY_ERROR = -104,
}
