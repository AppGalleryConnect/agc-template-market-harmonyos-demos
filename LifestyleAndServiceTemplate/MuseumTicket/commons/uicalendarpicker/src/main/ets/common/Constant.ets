

interface FontSizeConfig {
  year: Length;
  week: Length;
  day: Length;
  btn: Length;
  tip: Length;
}

interface MarginConfig {
  outerLeft: Length;
  outerTop: Length;
  yearToArrow: Length;
  arrowToArrow: Length;
  yearToWeek: Length;
  weekToDay: Length;
  dayToDay: number;
  dayLeft: number;
  dayTop: number;
}

export interface CalendarUIConfig {
  fontSize: FontSizeConfig;
  margin: MarginConfig;
}



export enum DialogType {
  /**
   * 常规弹窗
   */
  DIALOG = 'dialog',
  /**
   * 半模态弹窗
   */
  SHEET = 'sheet',
}

export enum SwiperDirection {
  /**
   * 水平方向滑动
   */
  HORIZONTAL = 'horizontal',
  /**
   * 竖直方向滑动
   */
  VERTICAL = 'vertical',
}

export enum TypePicker {
  /**
   * 单日期
   */
  SINGLE = 1,
  /**
   * 多日期
   */
  MULTIPLE = 2,
  /**
   * 时间段
   */
  RANGE = 3,
}

export enum Action {
  PRE = -1,
  NEXT = 1,
}

/**
 * 映射系统枚举
 */
export enum FORMAT_MAP {
  HOUR_12 = 'h12',
  HOUR_24 = 'h24',
}

export const configSM: CalendarUIConfig = {
  fontSize: {
    year: $r('sys.float.ohos_id_text_size_body1'),
    week: $r('sys.float.ohos_id_text_size_body2'),
    day: $r('sys.float.ohos_id_text_size_body2'),
    btn: $r('sys.float.ohos_id_text_size_button2'),
    tip: $r('sys.float.ohos_id_text_size_caption'),
  },
  margin: {
    outerLeft: 10,
    outerTop: 10,
    yearToArrow: 8,
    arrowToArrow: 24,
    yearToWeek: 4,
    weekToDay: 8,
    dayToDay: 4,
    dayLeft: 5,
    dayTop: 2,
  },
};

export const configLG: CalendarUIConfig = {
  fontSize: {
    year: $r('sys.float.ohos_id_text_size_headline8'),
    week: $r('sys.float.ohos_id_text_size_headline9'),
    day: $r('sys.float.ohos_id_text_size_headline9'),
    btn: $r('sys.float.ohos_id_text_size_headline9'),
    tip: $r('sys.float.ohos_id_text_size_body2'),
  },
  margin: {
    outerLeft: 10,
    outerTop: 10,
    yearToArrow: 16,
    arrowToArrow: 36,
    yearToWeek: 16,
    weekToDay: 0,
    dayToDay: 16,
    dayLeft: 5,
    dayTop: 2,
  },
};

// 默认可选的开始年份
export const START_YEAR = 1900;

// 默认可选的结束年份
export const END_YEAR = 2100;

// 针对时间段，最大跨度默认值
export const MAX_GAP_DEFAULT = 10000;

// List视图初始化，以指定月份为中心，前后各自加载的月份数量
export const LIST_CENTER_INDEX: number = 3;

// day宽度：容器宽度7等分
export const DAY_WIDTH: string = '14.28%';