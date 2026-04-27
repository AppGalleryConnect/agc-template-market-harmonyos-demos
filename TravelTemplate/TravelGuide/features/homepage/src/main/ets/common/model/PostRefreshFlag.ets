/**
 * 帖子刷新标记，用于页面间通信
 */
@ObservedV2
export class PostRefreshFlag {
  @Trace refreshPostId: string = ''

  constructor() {
    this.refreshPostId = ''
  }

  // 设置需要刷新的帖子ID
  setRefreshPostId(postId: string): void {
    this.refreshPostId = postId
  }

  // 清除刷新标记
  clear(): void {
    this.refreshPostId = ''
  }
}

