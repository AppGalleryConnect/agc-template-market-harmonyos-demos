import { PersistenceV2 } from '@kit.ArkUI'
import { UserInfo } from 'common'

// 帖子类型枚举
export enum PostType {
  HOME = 'home', // 主页帖子
  ATTRACTION_RECOMMEND = 'attraction_recommend', // 景点/攻略推荐
  ATTRACTION_LATEST = 'attraction_latest' // 景点/攻略最新
}

// 评论模型
@ObservedV2
export class Comment {
  @Trace id: string = Date.now().toString()
  // 评论用户信息（保留用于兼容）
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!
  // 评论用户昵称（独立字段，避免共享引用问题）
  @Trace nickName: string = ''
  // 评论用户头像（独立字段，避免共享引用问题）
  @Trace avatarUrl: ResourceStr = ''
  // 评论内容
  @Trace content: string = ''
  // 评论时间
  @Trace commentTime: string = ''
  // 评论地点
  @Trace commentLocation: string = ''
  // 点赞数量
  @Trace likes: number = 0
  // 是否点赞
  @Trace liked: boolean = false

  constructor(content: string, commentTime: string, commentLocation: string) {
    this.content = content
    this.commentTime = commentTime
    this.commentLocation = commentLocation
  }

  // 点赞事件
  handleLike() {
    this.liked = !this.liked
    this.likes = this.liked ? ++this.likes : --this.likes
  }
}

@ObservedV2
export class PostInfo {
  @Trace id: string = Date.now().toString()
  // 作者信息（保留用于兼容）
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!
  // 作者昵称（独立字段，避免共享引用问题）
  @Trace authorNickName: string = ''
  // 作者头像（独立字段，避免共享引用问题）
  @Trace authorAvatarUrl: ResourceStr = ''
  // 封面
  @Trace coverImg: ResourceStr | PixelMap = ''
  // 图片列表
  @Trace imgVideoList: ResourceStr[] = []
  // 视频资源（如果有视频）
  @Trace videoUrl: ResourceStr = ''
  // 标题
  @Trace title: string
  // 内容
  @Trace content: string
  // 发布时间
  @Trace publishTime: string
  // 发布地点
  @Trace publishLocation: string
  // 点赞数量
  @Trace likes: number = 0
  // 是否点赞
  @Trace liked: boolean = false
  // 浏览量
  @Trace views: number = 0
  // 评论列表
  @Trace comments: Comment[] = []
  // 评论数量
  @Trace commentCount: number = 0
  // 帖子类型
  @Trace postType: PostType = PostType.HOME
  // 帖子主题
  @Trace postTopic: string = ''

  constructor(title: string, content: string, publishTime: string, publishLocation: string) {
    this.title = title
    this.content = content
    this.publishTime = publishTime
    this.publishLocation = publishLocation
  }

  // 点赞事件
  handleLike() {
    this.liked = !this.liked
    this.likes = this.liked ? ++this.likes : --this.likes
  }
}


// 我发布的帖子
@ObservedV2
export class MyPostList {
  @Trace list: PostInfo[] = []
  // 用于触发监听的计数器，每次添加帖子时递增
  @Trace updateCount: number = 0

  add(data: PostInfo) {
    this.list.unshift(data)
    // 递增计数器以触发监听
    this.updateCount++
  }

  getDataById(id: string) {
    return this.list.find(item => item.id === id)
  }
}