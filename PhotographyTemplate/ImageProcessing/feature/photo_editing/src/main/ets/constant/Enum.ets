export enum CollageMode {
  FIXED = 'fixed',
  POSTER = 'poster',
  FREE = 'free',
  JOIN = 'join'
}

export enum ActionType {
  TOP_LEFT,
  TOP_RIGHT,
  BOTTOM_LEFT,
  BOTTOM_RIGHT,
  LEFT,
  RIGHT,
  TOP,
  BOTTOM,
  MOVE
}

// 图层操作类型
export enum LayerType {
  BASE = 'base', // 基础图层
  FILTER = 'filter', // 滤镜图层
  CLIP = 'clip', // 裁切图层
  ROTATE = 'rotate', // 旋转图层
  SCALE = 'scale', //
  STICKER = 'sticker', // 贴纸图层
  TEXT = 'text', // 文字图层
  MOSAIC = 'mosaic', // 马赛克图层
  SCRAWL = 'scrawl', // 涂鸦图层
  WATER = 'water', // 水印图层
}
