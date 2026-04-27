import { ShowMethod, SortEnum, ToolBarName } from './Enum'
import { NoteOperateType, ToolBar } from './Interface'

export const TOOL_BAR_LIST: ToolBar[] = [
  {
    name: ToolBarName.move_category,
    icon: $r('app.media.move_category')
  },
  {
    name: ToolBarName.delete,
    icon: $r('app.media.delete')
  },
  {
    name: ToolBarName.select_all,
    icon: $r('app.media.select_all')
  }
]

export const NOTE_SORT_TYPE_LIST: NoteOperateType[] = [
  {
    name: '按创建时间排序',
    type: SortEnum.CREATE_TIME
  },
  {
    name: '按修改时间排序',
    type: SortEnum.UPDATE_TIME
  }
]

export const NOTE_SHOW_TYPE_LIST: NoteOperateType[] = [
  {
    name: '按卡片展示',
    type: ShowMethod.waterFlowList
  },
  {
    name: '按列表展示',
    type: ShowMethod.normalList
  }
];

export const SNAPSHOT_ID = 'SNAPSHOT_ID'
export const RICH_ID = 'RICH_ID';
export const RICH_TEXT_MAX_LENGTH = 20000;
export const RICH_IMAGE_MAX_NUM = 20;
export const RICH_IMAGE_MAX_SIZE = 1; // GB

export interface MoreFunction {
  icon: ResourceStr,
  name: ResourceStr
}

export enum ACTION_NAME {
  share = '分享',
  copy = '复制'
}


export const MORE_ACTION_LIST: Array<MoreFunction> = [
  {
    icon: $r('app.media.share'),
    name: ACTION_NAME.share
  },
  {
    icon: $r('app.media.copy'),
    name: ACTION_NAME.copy
  }
]

// 原色滤镜
export const ORIGIN_COLOR_FILTER: ColorFilter = [
  1, 0, 0, 0, 0,
  0, 1, 0, 0, 0,
  0, 0, 1, 0, 0,
  0, 0, 0, 1, 0
];

// 高亮颜色滤镜
export const HIGHLIGHT_COLOR_FILTER: ColorFilter = [
  0, 0, 0, 0, 1,
  0, 0, 0, 0, 0.5,
  0, 0, 0, 0, 0,
  0, 0, 0, 1, 0
];

// 调色盘选项
export const COLOR_LIST: ResourceColor[] =
  ['#E5000000', '#FF774342', '#FFFFF200', '#FFFF7F27', '#FFED1C24',
    '#FFEF88BE', '#FFA349A4', '#FF00A2E8', '#FF22B14C', '#FF888888'];


export class DateConstants {
  /**
   * 2025-01-05 14:06:55
   */
  static readonly DATE_FORMAT1: string = 'yyyy-MM-dd HH:mm:ss';

  /**
   * 2025-01-05 14:06
   */
  static readonly DATE_FORMAT2: string = 'yyyy-MM-dd HH:mm';

  /**
   * 2025-01-05 14
   */
  static readonly DATE_FORMAT3: string = 'yyyy-MM-dd HH';

  /**
   * 2025-01-05
   */
  static readonly DATE_FORMAT4: string = 'yyyy-MM-dd';

  /**
   * 14:06:55
   */
  static readonly DATE_FORMAT5: string = 'HH:mm:ss';

  /**
   * 14:06
   */
  static readonly DATE_FORMAT6: string = 'HH:mm';

  /**
   * 2025/01/05 14:06:55
   */
  static readonly DATE_FORMAT7: string = 'yyyy/MM/dd HH:mm:ss';

  /**
   * 2025/01/05 14:06
   */
  static readonly DATE_FORMAT8: string = 'yyyy/MM/dd HH:mm';

  /**
   * 2025/01/05 14
   */
  static readonly DATE_FORMAT9: string = 'yyyy/MM/dd HH';

  /**
   * 2025/01/05
   */
  static readonly DATE_FORMAT10: string = 'yyyy/MM/dd';

  /**
   * 2025年01月05日 14时06分55秒135毫秒
   */
  static readonly DATE_FORMAT11: string = 'yyyy年MM月dd日 HH时mm分ss秒fff毫秒';

  /**
   * 2025年01月05日 14时06分55秒
   */
  static readonly DATE_FORMAT12: string = 'yyyy年MM月dd日 HH时mm分ss秒';

  /**
   * 2025年01月05日 14时06分
   */
  static readonly DATE_FORMAT13: string = 'yyyy年MM月dd日 HH时mm分';

  /**
   * 2025年01月05日 14时
   */
  static readonly DATE_FORMAT14: string = 'yyyy年MM月dd日 HH时';

  /**
   * 2025年01月05日
   */
  static readonly DATE_FORMAT15: string = 'yyyy年MM月dd日';

  /**
   * 14时06分55秒
   */
  static readonly DATE_FORMAT16: string = 'HH时mm分ss秒';

  /**
   * 14时06分
   */
  static readonly DATE_FORMAT17: string = 'HH时mm分';

  /**
   * 20250317
   */
  static readonly DATE_FORMAT18: string = 'yyyyMMdd';
}