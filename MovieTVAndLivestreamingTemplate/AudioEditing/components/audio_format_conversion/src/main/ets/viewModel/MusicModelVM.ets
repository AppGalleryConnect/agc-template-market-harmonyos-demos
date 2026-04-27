
import { SongItem } from 'audio_common';


@ObservedV2
export class MusicModel {
  @Trace windowsMode: number = 1
  @Trace isVip: boolean = false;
  @Trace isLogin: boolean = false;

  @Trace currentSong: SongItem | undefined = undefined; //当前播放歌曲
  @Trace totalTime: string = ''; // 总时长
  @Trace fileSize: number = 0; // 总时长
  @Trace progressMax: number = 0; // 进度条最大值
  @Trace progress: number = 0; // 进度
  @Trace currentTime: string = '00:00'; // 当前播放时长
  @Trace currentUrl: string = ''; // 当前播放时长

  // 私有静态实例变量
  private static instance: MusicModel | null = null;

  /**
   * 获取单例实例
   */
  public static getInstance(): MusicModel {
    if (!MusicModel.instance) {
      MusicModel.instance = new MusicModel();
    }
    return MusicModel.instance;
  }

}

export function getMusicModel(): MusicModel {
  return MusicModel.getInstance();
}
