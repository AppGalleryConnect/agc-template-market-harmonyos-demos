@ObservedV2
export class VideoInfo {
  @Trace id: string;
  @Trace name: string;
  @Trace url: ResourceStr;
  @Trace size: number; // 单位：字节
  @Trace duration: number; // 单位：秒
  @Trace sizeCurrent: string; //已缓存进度
  @Trace thumbnail?: Resource; // 缩略图URL（可选）
  @Trace isCached?: boolean; //是否缓存完成
  @Trace currentCachePercent?: number; //缓存进度百分比
  @Trace isDownloading?: boolean; //是否正在下载


  constructor(id: string, name: string, url: Resource, size: number, duration: number, sizeCurrent: string,
    thumbnail?: Resource, isCached?: boolean, currentCachePercent?: number, isDownloading?: boolean) {
    this.id = id;
    this.name = name;
    this.url = url;
    this.size = size;
    this.duration = duration;
    this.sizeCurrent = sizeCurrent;
    this.thumbnail = thumbnail;
    this.isCached = isCached;
    this.currentCachePercent = currentCachePercent;
    this.isDownloading = isDownloading ?? false;
  }

  // 获取格式化的大小显示
  getFormattedSize(): string {
    if (this.size < CommonConstants.BYTES_PER_MB) {
      return `${(this.size / 1024).toFixed(2)} KB`;
    }
    return `${(this.size / CommonConstants.BYTES_PER_MB).toFixed(0)}`;
  }

  // 获取格式化的时长显示
  getFormattedDuration(): string {
    const minutes: number = Math.floor(this.duration / 60);
    const seconds: number = this.duration % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }
}

@ObservedV2
export class CommonConstants {
  @Trace static readonly VIDEO_HTTPS_LISTS: Array<VideoInfo> = [
    new VideoInfo(
      '0001',
      '视频1',
      $r('app.string.video1_url'),
      4165357,
      13,
      '0K',
      $r('app.media.cover_video1'),
      false,
      0,
      false
    ),
    new VideoInfo(
      '0002',
      '视频2',
      $r('app.string.video2_url'),
      2580421,
      9,
      '0K',
      $r('app.media.cover_video2'),
      false,
      0,
      false
    ),
  ];
  @Trace static readonly BUTTON_SIZE: string = '30vp';
  @Trace static readonly BYTES_PER_MB: number = 1048576;
}

