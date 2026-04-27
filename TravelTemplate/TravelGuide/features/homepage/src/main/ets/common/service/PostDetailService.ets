import { PostInfo } from 'common_travel_guide'
import { getPostDetailById as getPostDetailByIdFromMock, updatePostDetail as updatePostDetailInMock } from '../mock/PostDetailMockData'

/**
 * 帖子详情服务类，用于管理帖子详情数据
 * 使用 @ObservedV2 和 @Trace 装饰器，支持 @Monitor 监听
 */
@ObservedV2
export class PostDetailService {
  // 单例模式
  static instance: PostDetailService = new PostDetailService()

  // 当前正在查看的帖子详情（用于 @Monitor 监听）
  @Trace currentPostDetail: PostInfo | null = null
  @Trace currentPostId: string = ''

  private constructor() {
  }

  /**
   * 获取帖子详情
   * @param id 帖子ID
   * @returns 帖子详情
   */
  getPostDetailById(id: string): PostInfo | undefined {
    return getPostDetailByIdFromMock(id)
  }

  /**
   * 更新帖子详情
   * @param post 帖子详情
   */
  updatePostDetail(post: PostInfo): void {
    // 更新到 mock 数据
    updatePostDetailInMock(post)
    
    // 如果当前正在查看的帖子被更新，则更新 currentPostDetail
    // 重新赋值以触发 @Monitor 监听
    if (this.currentPostId === post.id) {
      const updatedPost = this.getPostDetailById(post.id)
      if (updatedPost) {
        // 重新赋值以触发响应式更新
        this.currentPostDetail = updatedPost
      }
    }
  }

  /**
   * 设置当前正在查看的帖子
   * @param postId 帖子ID
   */
  setCurrentPost(postId: string): void {
    this.currentPostId = postId
    const post = this.getPostDetailById(postId)
    if (post) {
      this.currentPostDetail = post
    }
  }

  /**
   * 清除当前正在查看的帖子
   */
  clearCurrentPost(): void {
    this.currentPostId = ''
    this.currentPostDetail = null
  }
}

