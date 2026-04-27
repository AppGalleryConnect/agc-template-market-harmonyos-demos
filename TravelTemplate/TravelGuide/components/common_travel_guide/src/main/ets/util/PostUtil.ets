import { SecureRandomUtil } from 'common'
import { PostInfo, PostType } from '../model/PostModel'

/**
 * 帖子数据访问接口
 * 由具体实现类提供数据访问方法
 */
export interface IPostDataAccess {
  getAllPosts(): PostInfo[]
  getPostDetailMap(): Map<string, PostInfo>
}

// 全局数据访问器（需要在应用初始化时设置）
let postDataAccess: IPostDataAccess | null = null

/**
 * 设置帖子数据访问器
 * @param accessor 数据访问器实例
 */
export function setPostDataAccess(accessor: IPostDataAccess): void {
  postDataAccess = accessor
}

/**
 * 添加主页帖子
 * @param post 要添加的帖子对象（会自动设置 postType 为 HOME，并生成 id）
 * @returns 添加后的帖子对象（包含生成的 id）
 */
export function addHomePagePost(post: PostInfo): PostInfo {
  if (!postDataAccess) {
    throw new Error('PostDataAccess not initialized. Please call setPostDataAccess() first.')
  }

  // 生成唯一 id（使用时间戳 + 随机数）
  if (!post.id || post.id === '') {
    post.id = `h_${Date.now()}_${SecureRandomUtil.getRandomNumber(100).toString(36).substring(2, 9)}`
  }
  
  // 确保 postType 为 HOME
  post.postType = PostType.HOME
  
  // 设置默认值
  if (!post.coverImg) {
    post.coverImg = post.imgVideoList && post.imgVideoList.length > 0 
      ? post.imgVideoList[0] 
      : $r('app.media.startIcon')
  }
  
  if (!post.authorNickName) {
    post.authorNickName = post.userInfo?.nickName || '我'
  }
  
  if (!post.authorAvatarUrl) {
    post.authorAvatarUrl = post.userInfo?.avatarUrl
  }
  
  if (!post.publishTime) {
    const now = new Date()
    post.publishTime = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
  }
  
  if (!post.comments) {
    post.comments = []
  }
  
  if (post.commentCount === undefined) {
    post.commentCount = post.comments.length
  }
  
  // 获取所有帖子数组和详情Map
  const allPosts = postDataAccess.getAllPosts()
  const postDetailMap = postDataAccess.getPostDetailMap()
  
  // 添加到 allPosts 数组的开头（新帖子显示在最前面）
  allPosts.unshift(post)
  
  // 更新 postDetailMap
  postDetailMap.set(post.id, post)
  
  return post
}

/**
 * 获取更新后的主页帖子列表
 * @returns 当前的主页帖子列表
 */
export function getHomePagePostList(): PostInfo[] {
  if (!postDataAccess) {
    throw new Error('PostDataAccess not initialized. Please call setPostDataAccess() first.')
  }
  
  const allPosts = postDataAccess.getAllPosts()
  return allPosts.filter(post => post.postType === PostType.HOME)
}

