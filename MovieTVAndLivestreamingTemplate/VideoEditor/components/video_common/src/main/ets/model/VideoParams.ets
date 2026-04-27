import { image } from '@kit.ImageKit'

export interface IVideoFormData {
  coverResource: Resource,
  title: string,
  videoFileSizeMB: number,
  duration: number
}

export interface BasicVideoData {
  basicUrl: string
  frameList: FrameListData[],
  index: number,
  startTime: number,
  endTime: number,
  duration: number,
  leftShort: number,
  splitLeft: number,
  scroller: Scroller
  keyId: string,
  videoWidth: number,
  videoHeight: number
}

export interface PipVideoData {
  isEdit: boolean,
  pipUrl: string,
  frameList: FrameListData[],
  startTime: number,
  endTime: number,
  duration: number,
  keyFrame: image.PixelMap,
  width: number,
  height: number,
  offsetX: number,
  offsetY: number
}

export interface VideoParam{
  showHandler: boolean,
  leftHandler: number,
  rightHandler: number,
  width: number
}

@ObservedV2
export class  FrameListData{
  @Trace index: number = 0
  @Trace mPixelMap: image.PixelMap | undefined = undefined
  @Trace url: string = ''
}