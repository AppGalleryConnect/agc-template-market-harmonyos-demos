export enum TrimType {
  DragSeekLine,
  DragLeftBar,
  DragRightBar,
  SplitLine,
  DragThumbnail,
  DragLeftSplitLine,
  DragRightSplitLine,
  PinchThumbnail,
  Idle
}

export enum ReportPressType {
  LONG_PRESS = 'long_press',
  SLIDE = 'false'
}

export enum ReportTrimHandle {
  LEFT = 'trim_left',
  RIGHT = 'trim_ right'
}

export enum StickerType {
  NEW = 'new',
  HOT = 'hot'
}

export enum TextSettingType {
  STYLE = 0,
  TEXT = 1
}

export enum YAdsorbType {
  NONE = -1,
  TOP = 0, // 吸附到上边界（minY）
  CENTER = 1, // 吸附到中心（y=0）
  BOTTOM = 2 // 吸附到下边界（maxY）
}

export enum GestureState {
  NONE,
  TAP, // 点击
  PAN, // 平移
  ROTATE, // 双指旋转
  PINCH // 双指缩放
}

export enum XAdsorbType {
  NONE = -1,
  LEFT = 0, // 吸附到左边界（minX）
  CENTER = 1, // 吸附到中心（x=0）
  RIGHT = 2 // 吸附到右边界（maxX）
}