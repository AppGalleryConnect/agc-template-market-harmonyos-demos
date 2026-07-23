import { AuthorResponse, CommentResponse, NewsEnum, NewsResponse, PostImgList } from 'lib_news_api';
import { VideoPlayerData } from 'module_swipeplayer';

export class TabNav {
  id: string = ''
  name: string = ''
  activeColor: ResourceColor = ''

  constructor(id: string, name: string, activeColor: ResourceColor = Color.White) {
    this.id = id;
    this.name = name;
    this.activeColor = activeColor;
  }
}

@ObservedV2
export class VideoNewsData implements NewsResponse, VideoPlayerData {
  // 内容id
  id: string = ''
  // 新闻类型
  type: NewsEnum = NewsEnum.Video
  // 标题
  title: string = ''
  // 作者
  author: AuthorResponse = {} as AuthorResponse
  // 创建时间
  createTime: number = 0
  // 评论列表
  comments: CommentResponse[] = []
  // 收藏数量
  markCount: number = 0
  // 点赞数量
  likeCount: number = 0
  // 分享数量
  shareCount: number = 0
  // 是否被点赞
  isLiked: boolean = false
  // 是否被收藏
  isMarked: boolean = false
  // 评论数
  commentCount: number = 0
  // 视频url
  videoUrl: string = ''
  // 封面图
  coverUrl: string = ''
  // 视频时长(单位: 毫秒)
  videoDuration: number = 0
  // 图片链接
  postImgList?: PostImgList[]
  // 直播开始时间（毫秒时间戳）
  liveStartTime: number
  // 直播结束时间（毫秒时间戳）
  liveEndTime: number

  getVideoId(): string {
    return this.id;
  }

  getVideoUrl(): string {
    return this.videoUrl;
  }

  getCoverUrl(): string {
    return this.coverUrl;
  }

  getVideoTitle(): string {
    return this.title;
  }

  getVideoDuration(): number {
    return this.videoDuration;
  }

  getAuthorName(): string {
    return this.author.authorNickName;
  }

  /**
   * 视频资源是否需要vip会员解锁观看
   * @returns
   */
  isNeedVip() {
    return false;
  }

  /**
   * 设置视频时长
   * @param duration
   */
  setVideoDuration(duration: number) {
    this.videoDuration = duration;
  }

  constructor(data: NewsResponse) {
    this.id = data.id
    this.title = data.title
    this.type = data.type
    this.author = data.author
    this.comments = data.comments
    this.markCount = data.markCount
    this.likeCount = data.likeCount
    this.isLiked = data.isLiked
    this.isMarked = data.isMarked
    this.commentCount = data.commentCount
    if (!data.videoUrl && data.postImgList?.length) {
      this.videoUrl = data.postImgList[0].picVideoUrl
      this.coverUrl = data.postImgList[0].surfaceUrl
    } else {
      this.videoUrl = data.videoUrl!
      this.coverUrl = data.coverUrl!
    }
    this.videoDuration = data.videoDuration!
    this.createTime = data.createTime!
    this.liveStartTime = data.liveStartTime ?? 0
    this.liveEndTime = data.liveEndTime ?? 0
  }
}