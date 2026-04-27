import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { media } from '@kit.MediaKit';

export class Constants {
  static readonly FULL_PERCENT: string = '100%';
  static readonly TITLE_HEIGHT: number = 56;
  static readonly TITLE_ICON_WIDTH: number = 40;
  static readonly ICON_WIDTH: number = 24;
  static readonly SPACE_8: number = 8;
  static readonly PADDING_16: number = 16;
  static readonly MAX_TEXTAREA_HEIGHT: number = 140;
  static readonly ACTION_BAR_HEIGHT: number = 44;
  static readonly MAX_BODY_WORD_LIMIT: number = 800;
  static readonly MAX_IMG_COUNT: number = 18;
  static readonly MAX_VIDEO_COUNT: number = 1;
  static readonly MAX_VIDEO_SIZE: number = 500;
  static readonly DEFAULT_LOCATION_TEXT = '添加位置';
}

export interface ImageContent {
  src: string;
  movingPhoto?: photoAccessHelper.MovingPhoto;
}

export class PostImgVideoItem {
  id: number = 0
  picVideoUrl: string = ''
  surfaceUrl: string = ''
  movingPhoto?: photoAccessHelper.MovingPhoto;
}

export interface MediaParams {
  type: photoAccessHelper.PhotoViewMIMETypes
  maxLimit: number
  maxSize?: number
}

export class VideoSizeData {
  public photoSize: media.PixelMapParams = {
    width: 0,
    height: 0,
  };
  public totalTime: number = 0;
}

/**
 * 上传类型
 */
export enum UploadType {
  Image = 1,
  Video,
}


// 发布动态-图片参数
export const DEFAULT_IMAGE_PARAM: MediaParams = {
  type: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
  maxLimit: Constants.MAX_IMG_COUNT,
}

// 发布动态-视频参数
export const DEFAULT_VIDEO_PARAM: MediaParams = {
  type: photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE,
  maxLimit: Constants.MAX_VIDEO_COUNT,
  maxSize: Constants.MAX_VIDEO_SIZE,
}

export const GRID_ROW_OPTIONS: GridRowOptions = {
  columns: {
    sm: 4,
    md: 8,
    lg: 12,
    xl: 12,
  },
  gutter: {
    x: {
      sm: 8,
      md: 12,
      lg: 16,
      xl: 20,
    },
  },
  breakpoints: {
    value: ['0', '600vp', '840vp', '1440vp'],
    reference: BreakpointsReference.WindowSize,
  },
  direction: GridRowDirection.Row,
};

export const COL_SPAN: GridColColumnOption = {
  sm: 4,
  md: 8,
  lg: 8,
  xl: 8,
};

export const COL_OFFSET: GridColColumnOption = {
  sm: 0,
  md: 0,
  lg: 2,
  xl: 2,
};

export const GRID_MARGIN: GridRowColumnOption = {
  sm: 16,
  md: 24,
  lg: 32,
  xl: 32,
};