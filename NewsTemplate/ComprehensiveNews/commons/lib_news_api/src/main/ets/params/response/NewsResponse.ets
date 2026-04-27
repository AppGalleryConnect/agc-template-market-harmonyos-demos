import { NewsEnum, VideoEnum } from '../../constants/Constants';
import { NavInfo, PostImgList } from '../base/BaseModel';
import { AuthorResponse } from './AuthorResponse';
import { CommentResponse } from './CommentResponse';

/**
 * 新闻内容-云侧接口响应模型
 */
export interface NewsResponse {
  // 内容id
  id: string
  // 新闻类型
  type: NewsEnum
  // 标题
  title: string
  // 作者
  author: AuthorResponse
  // 创建时间
  createTime: number
  // 相对时间
  relativeTime?: string
  // 评论列表
  comments: CommentResponse[]
  // 评论数
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
  // 富文本
  richContent?: string
  // 相关推荐
  recommends?: NewsResponse[]
  // 视频url
  videoUrl?: string
  // 封面图
  coverUrl?: string
  // 视频类型
  videoType?: VideoEnum
  // 视频时长(单位: 毫秒)
  videoDuration?: number
  // 正文
  postBody?: string
  // 图片链接
  postImgList?: PostImgList[]
  // 动态布局参数
  navInfo?: NavInfo
  // 额外信息
  extraInfo?: Record<string, string | number | boolean | Record<string, string | boolean>[]>
  // 播放次数
  playCount?: string
  // 总数
  totalCount?: number
  // 关联文章id
  relationId?: string
  // 直播开始时间（毫秒时间戳）
  liveStartTime?: number
  // 直播结束时间（毫秒时间戳）
  liveEndTime?: number
  // 新闻标签
  tags?: string[]
}