import { FileBaseInfo } from 'cloud_file_base';

// 文件tab主页，面包屑导航页通用viewmodel
@ObservedV2
export class ImageVideoPageVM {
  fileInfo: FileBaseInfo;
  downloadFunc: () => void = () => {
  }
  popPageFunc: () => void = () => {
  }
  renameFunc: (text: string) => void = () => {
  }
  deleteFunc: () => void = () => {
  }
  shareFunc: () => void = () => {
  }

  constructor(fileInfo: FileBaseInfo, downloadFunc: () => void, popPageFunc: () => void) {
    this.fileInfo = fileInfo
    this.downloadFunc = downloadFunc
    this.popPageFunc = popPageFunc
  }

  // 当前排序索引
  @Trace currentIndex: number = 1;
  // 播放速度
  @Trace curRate: number = 1
  // 是否播放
  @Trace isPlaying: boolean = false
  // 视频音频当前时间
  @Trace currentTime: number = 0
  //视频音频总时长
  @Trace duration: number = 0
  @Trace intervalId: number = 0
  //查看原图
  @Trace originally: boolean = true
  // 弹框id，用于关闭
  dialogId: number = 0;
  // 播放速度列表
  private _timesList: string[] = [
    '0.75倍',
    '1.0倍',
    '1.25倍',
    '1.5倍',
    '2倍'
  ];
  private _imgTimes: Resource[] = [
    $r('app.media.ic_zero_point_sevenfivetimes'),
    $r('app.media.ic_onetimes'),
    $r('app.media.ic_one_point_twofivetimes'),
    $r('app.media.ic_one_point_fivetimes'),
    $r('app.media.ic_twotimes'),
  ];

  public get timesList(): string[] {
    return this._timesList;
  }

  public get imgTimes(): Resource[] {
    return this._imgTimes;
  }
}