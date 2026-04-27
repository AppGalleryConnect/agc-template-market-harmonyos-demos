import { image } from '@kit.ImageKit';
import { avSession } from '@kit.AVSessionKit';

export enum PermissionStatus {
  GRANTED = 0,
  DENIED = -1,
  UNKNOWN = 2,
}


export enum MediaType {
  AUDIO = 0,
  VIDEO = 1
}


// 视频文件信息
export interface MediaInfo {
  name: string,
  size: string,
  duration: number,
  type: MediaType,
  url: string,
  headImg: image.PixelMap
}


@ObservedV2
export class CastStatusModel {
  @Trace public isCasting: boolean = false;
  @Trace isCastPlaying: boolean = false;
  @Trace castCurrentTime: number = 0;
  @Trace castDuration: number = 0;
  @Trace castResolution: string = '';
  @Trace castVolume: number = 0;
  @Trace castMaxVolume: number = 100;
  @Trace currentDeviceName: string = '';
  @Trace currentDeviceType: avSession.DeviceType = avSession.DeviceType.DEVICE_TYPE_LOCAL;
}

export interface CastSessionListener {
  onStartCasting(): void;

  onEndCasting(): void;

  onPlay(): void;

  onPause(): void;

  onPlayNext(): void;

  onPlayPre(): void;

  onSeek(time: number): void;

  onFastForward(time: number): void;

  onRewind(time: number): void;
}


export interface MediaData {
  url?: string,
  name: string,
  head: string | image.PixelMap,
  id: string,
  sortId: number,
  duration: number,
  mediaType: MediaType,
}


// 投屏控制中心的参数
export interface CastParams {
  mediaList: MediaData[],
  selectIndex: number,
  mediaType: MediaType
}