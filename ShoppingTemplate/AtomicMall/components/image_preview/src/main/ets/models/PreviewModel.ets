import { photoAccessHelper } from '@kit.MediaLibraryKit';

/**
 * 数据源模型
 * */
export interface SourceModel {
  imageUrl: PreviewImgType
  videoUrl?: string
  movingPhoto?: photoAccessHelper.MovingPhoto | undefined
}

/**
 * 数据源构造类
 * */
export class SourceImageModel {
  imageUrl: PreviewImgType;
  videoUrl?: string;
  movingPhoto?: photoAccessHelper.MovingPhoto | undefined;

  constructor(sourceInfo: SourceModel) {
    this.imageUrl = sourceInfo.imageUrl;
    this.videoUrl = sourceInfo.videoUrl ?? '';
    this.movingPhoto = sourceInfo.movingPhoto ?? undefined;
  }
}

/**
 * 图片类型
 * */
export enum DefaultImageType {
  IMAGE,
  LIVE_PHOTO
}

/**
 * 中心坐标点
 * */
export interface CenterLocation {
  x: number;
  y: number;
}

/**
 * 缩放状态组件信息
 * */
export interface ScaleImageInfo {
  width: number
  height: number
  localLeft: number
  localTop: number
}

/**
 * 缩略图size
 * */
export interface ThumbnailSize {
  width: number
  height: number
}

/**
 * 组件信息
 * */
export interface PreviewComponentInfo {
  width: number
  height: number
  contentOffsetY: number
  contentOffsetX: number
}

/**
 * 弹窗关闭参数
 * */
export interface PreviewCloseParam {
  dialogId?: string
  animated?: boolean
}

/**
 * 组件信息类型
 */
export interface ComInfoType {
  width: number
  height: number
  localLeft: number
  localTop: number
  screenLeft: number
  screenTop: number
  windowTop: number
  windowLeft: number
}

export type PreviewImgType = PixelMap | ResourceStr | DrawableDescriptor;

export type MovingImageType = photoAccessHelper.MovingPhoto;
