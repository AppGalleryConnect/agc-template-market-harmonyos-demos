import { AvSection } from 'lib_tv_apis'
import { VideoPlayerData } from 'module_swipeplayer'

@ObservedV2
export class VideoData implements VideoPlayerData {
  id: string = ''
  title: string = ''
  duration: number = 0
  updateTime: string = ''
  sectionUrl: string = ''
  coverUrl: string = ''
  authorNickName: string = ''
  @Trace needVip: boolean = false;

  getVideoId(): string {
    return this.id;
  }

  getVideoUrl(): string {
    return this.sectionUrl;
  }

  getCoverUrl(): string {
    return this.coverUrl;
  }

  setCoverUrl(url: string) {
    this.coverUrl = url;
  }

  getVideoTitle(): string {
    return this.title;
  }

  getVideoDuration(): number {
    return this.duration;
  }

  getAuthorName() {
    return this.authorNickName;
  }

  /**
   * 视频资源是否需要vip会员解锁观看
   * @returns
   */
  public isNeedVip() {
    return this.needVip;
  }

  /**
   * 设置视频时长
   * @param duration
   */
  public setVideoDuration(duration: number) {
    this.duration = duration;
  }

  constructor(data: AvSection, authorName?: string) {
    this.id = data.id
    this.title = data.title
    this.sectionUrl = data.sectionUrl!
    this.coverUrl = data.coverUrl
    this.duration = data.duration!
    this.updateTime = data.updateTime!
    this.authorNickName = authorName ?? '';
  }
}