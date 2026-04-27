export class CommonConstants {
  static readonly ZERO: number = 0;
  static readonly ZERO_POINT_ONE: number = 0.1;
  static readonly ONE: number = 1;
  static readonly THREE: number = 3;
  static readonly TEN: number = 10;
  static readonly TWENTY: number = 20;
  static readonly ONE_HUNDRED: number = 100;
  static readonly COLOR_STRING: string = '';
  static readonly BLACK: string = 'black';
  static readonly ONE_HUNDRED_PERCENT: string = '100%';
  static readonly DRAW_BOARD_ID = 'drawBoard' // 组件canvas的id
  static readonly CROP_AREA = 'crop_area' // 图片裁切的组件id
  static readonly WINDOW_NAME = 'sheetMenu'; //窗口名称
  static readonly COLOR_ARR: string[] = [
    '#FFFFFF', '#1A000000', '#33000000', '#66000000',
    '#80000000', '#99000000', '#E6000000', '#FF000000',
    '#E52424', '#E56224', '#F6C800', '#63B959',
    '#48ADDD', '#5445EF', '#A946F1', '#F146CE',
    '#FF8888', '#FF7E71', '#FFE264', '#97FF8A',
    '#46B1E3', '#978DFF', '#E8C8FF', '#FAC6F0',
  ]
  static readonly LINEAR_GRADIENT_ARR: Array<[ResourceColor, number]> [] = [
    [[0xFFFFDADA, 0.0], [0xFFFF8888, 1]],
    [[0xFFFFE5DA, 0.0], [0xFFFF9E71, 1]],
    [[0xFFFFF7D6, 0.0], [0xFFFFE264, 1]],
    [[0xFFE0FFDC, 0.0], [0xFF97FF8A, 1]],
    [[0xFFE2F6FF, 0.0], [0xFFA1E1FF, 1]],
    [[0xFFE0DDFF, 0.0], [0xFF978DFF, 1]],
    [[0xFFF8EEFF, 0.0], [0xFFE8C8FF, 1]],
    [[0xFFFDEEFA, 0.0], [0xFFFAC6F0, 1]],
    [[0xFFDAF3DD, 0.0], [0xFFFFDE97, 1]],
    [[0xFFCAEEFF, 0.0], [0xFFF5B4BA, 1]],
    [[0xFF66DAE6, 0.0], [0xFFC0BEFD, 1]],
    [[0xFFDEDEDE, 0.0], [0xFF646D78, 1]],
  ]
}

/**
 * 图形类型枚举
 */
export enum ShapeType {
  NONE = 'none', // 无图形
  CIRCLE = 'circle', // 圆形
  RECTANGLE = 'rectangle', // 矩形
  LINE = 'line' // 直线
}
