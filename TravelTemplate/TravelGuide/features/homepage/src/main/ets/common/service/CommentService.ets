import { Comment, PostInfo } from 'common_travel_guide'
import { getCurrentCityInfo } from 'common'

/**
 * 评论服务类，用于处理评论相关的业务逻辑
 */
export class CommentService {
  // 单例模式
  static instance: CommentService = new CommentService()

  private constructor() {
  }

  /**
   * 提交评论
   * @param commentText 评论内容
   * @param detail 帖子详情
   * @returns 新创建的评论对象，如果失败返回null
   */
  async submitComment(commentText: string, detail: PostInfo | null): Promise<Comment | null> {
    if (!commentText.trim() || !detail) {
      return null
    }

    // 获取当前城市定位
    let commentLocation: string = '未知'
    try {
      const cityInfo = await getCurrentCityInfo()
      if (cityInfo && cityInfo.locality) {
        commentLocation = cityInfo.locality
      }
    } catch (e) {
      // 定位失败，使用默认值"未知"
      commentLocation = '未知'
    }

    // 创建新评论
    const newComment = new Comment(
      commentText.trim(),
      new Date().toISOString().split('T')[0],
      commentLocation
    )
    newComment.id = `comment_${Date.now()}`
    newComment.nickName = '我'
    newComment.avatarUrl = $r('app.media.path2x')
    newComment.likes = 0

    // 添加到评论列表
    if (!detail.comments) {
      detail.comments = []
    }
    detail.comments.unshift(newComment)
    detail.commentCount = detail.comments.length

    return newComment
  }

  /**
   * 提交评论（PostDetailPage版本，包含深拷贝逻辑）
   * @param commentText 评论内容
   * @param detail 帖子详情
   * @returns 新创建的评论对象，如果失败返回null
   */
  async submitCommentWithDeepCopy(commentText: string, detail: PostInfo | null): Promise<Comment | null> {
    if (!commentText.trim() || !detail) {
      return null
    }

    // 获取当前城市定位
    let commentLocation: string = '未知'
    try {
      const cityInfo = await getCurrentCityInfo()
      if (cityInfo && cityInfo.locality) {
        commentLocation = cityInfo.locality
      }
    } catch (e) {
      // 定位失败，使用默认值"未知"
      commentLocation = '未知'
    }

    // 创建新评论
    const newComment = new Comment(
      commentText.trim(),
      new Date().toISOString().split('T')[0],
      commentLocation
    )
    newComment.id = `comment_${Date.now()}`
    newComment.nickName = '我'
    newComment.avatarUrl = $r('app.media.path2x')
    newComment.likes = 0

    // 深拷贝现有评论列表，确保每个评论都有独立的字段
    const existingComments = detail.comments?.map((comment) => {
      const cloned = new Comment(comment.content, comment.commentTime, comment.commentLocation)
      cloned.id = comment.id
      cloned.nickName = comment.nickName || ''
      cloned.avatarUrl = comment.avatarUrl || ''
      cloned.likes = comment.likes
      cloned.liked = comment.liked
      return cloned
    }) || []
    
    // 将新评论添加到列表开头
    detail.comments = [newComment, ...existingComments]
    detail.commentCount = detail.comments.length

    return newComment
  }
}
