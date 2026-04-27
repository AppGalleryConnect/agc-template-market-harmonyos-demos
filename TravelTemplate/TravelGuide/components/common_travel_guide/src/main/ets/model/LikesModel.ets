@ObservedV2
export class LikesItem {
  // 点赞人昵称
  @Trace userName: string
  // 点赞人头像
  @Trace avatar: ResourceStr
  // 点赞时间
  @Trace time: string
  // 点赞帖子ID
  @Trace postId: string
  // 点赞帖子封面
  @Trace postCover: ResourceStr | PixelMap

  constructor(userName: string, avatar: ResourceStr, time: string, postId: string, postCover: ResourceStr | PixelMap) {
    this.userName = userName
    this.avatar = avatar
    this.time = time
    this.postId = postId
    this.postCover = postCover
  }
}

// 我被点赞的列表
@ObservedV2
export class MyLikeList {
  @Trace list: LikesItem[] = []

  add(data: LikesItem) {
    this.list.unshift(data)
  }

  deleteById(id: string) {
    this.list = this.list.filter(item => item.postId !== id)
  }
}