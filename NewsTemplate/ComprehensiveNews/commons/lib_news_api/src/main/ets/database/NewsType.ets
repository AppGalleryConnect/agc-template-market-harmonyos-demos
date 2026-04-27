import { NewsEnum, VideoEnum } from '../constants/Constants';
import { IButtonItem, NavInfo, PostImgList } from '../params/base/BaseModel';

export interface SimpleNews {
  // 新闻id
  newsId: string;
  // 新闻类型
  newsType: NewsEnum;
}

export interface KeyWordPair {
  // 新闻关键字
  keyword: string;
  // 新闻关键字解释
  explain: string;
}

export interface QuestionsAndAnswer {
  // 新闻问题
  question: string;
  // 新闻回答
  answer: string;
}

/**
 * 新闻基础字段（文章、视频、动态）
 */
export interface BaseNews {
  // 新闻id
  id: string
  // 新闻类型
  type: NewsEnum
  // 标题
  title: string
  // 作者
  authorId: string
  // 创建时间
  createTime: number
  // 评论总数
  commentCount: number
  // 收藏数量
  markCount: number
  // 点赞数量
  likeCount: number
  // 分享数量
  shareCount: number
  // 是否被点赞
  isLiked: boolean
  // 是否被收藏
  isMarked: boolean
  // 文章-富文本
  richContent?: string
  // 文章-相关推荐
  recommends?: SimpleNews[]
  // 视频-视频url
  videoUrl?: string
  // 视频-封面图
  coverUrl?: string
  // 视频-视频类型
  videoType?: VideoEnum
  // 视频时长(单位: 毫秒)
  videoDuration?: number
  // 动态-正文
  postBody?: string
  // 动态-图片链接
  postImgList?: PostImgList[]
  // 动态布局参数
  navInfo: NavInfo
  // 额外信息
  extraInfo?: IButtonItem[]
  totalCount?: number
  publishTime?: string
  playCount?: string
  isLocalPublish?: boolean
  questionAndAnswer?: QuestionsAndAnswer
  keywordPairs?: KeyWordPair[]
  // 直播开始时间（毫秒时间戳）
  liveStartTime?: number
  // 直播结束时间（毫秒时间戳）
  liveEndTime?: number
  // 标签
  tags: string[]
  // 城市定位
  city?: string
}
