/***
 * 动态布局信息
 */
export class NavInfo {
  setting: string = ''
}

/**
 * 动态图片/视频
 */
export interface PostImgList {
  picVideoUrl: string
  movingVideoUrl?: string
  id?: string
  surfaceUrl: string
  type?: number
  essayId?: string
}

/**
 * 按钮信息
 */
export interface IButtonItem {
  id: string;
  label: string;
}