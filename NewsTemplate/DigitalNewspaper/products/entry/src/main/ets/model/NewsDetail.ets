/**
 * 新闻文章
 */
export class NewsArticle {
  // 新闻id
  id: string = ''
  // 标题
  title: string = ''
  // 作者
  authorId?: string
  // 创建时间
  createTime: number = 0
  // 创建日期
  createDate?: string
  // 评论总数
  commentCount?: number
  // 收藏数量
  markCount?: number
  // 点赞数量
  likeCount?: number
  // 分享数量
  shareCount?: number
  // 是否被点赞
  isLiked?: boolean
  // 是否被收藏
  isMarked?: boolean
  // 文章-富文本
  richContent?: string
}

/**
 * 动态图片/视频
 */
export interface PostImgList {
  picVideoUrl: string
  movingVideoUrl?: string
  id?: string
  surfaceUrl: string
  type?: number
  essayId?: string
}