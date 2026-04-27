@ObservedV2
export class VideoModel {
  @Trace isPlaying: boolean;
  @Trace videoName: string;
  @Trace playStatus: boolean;

  constructor(isPlaying?: boolean, videoName?: string) {
    this.isPlaying = false
    this.videoName = ''
    this.playStatus = false //视频播放处于播放状态还是暂停状态
  }
}