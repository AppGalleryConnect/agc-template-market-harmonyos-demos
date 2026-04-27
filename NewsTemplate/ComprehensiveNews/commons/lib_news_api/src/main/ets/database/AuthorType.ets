/**
 * 用户数据库字段
 */
export interface BaseAuthor {
  // 作者id
  authorId: string
  //作者昵称
  authorNickName: string
  // 作者icon
  authorIcon: string
  //作者简介
  authorDesc: string
  // 手机号
  authorPhone?: string
  // 作者ip
  authorIp: string
  // 关注的人
  watchers: string[]
  // 订阅号
  subscribe: string[]
  // 粉丝
  followers: string[]
  // 获赞数量
  likeNum: number
}

/**
 * 预约信息接口
 */
export interface ReservationInfo {
  // 新闻id
  newsId: string
  // 直播开始时间（毫秒时间戳）
  liveStartTime: number
  // 添加到日历日程的事件id
  eventId: number
}

/**
 * 本人数据库字段
 */
export interface MyAuthor extends BaseAuthor {
  // 我的点赞
  myLikes: string[]
  // 我的收藏
  myMarks: string[]
  // 我的评论
  myComments: string[]
  // 阅读历史
  myHistory: string[]
  // 我的预约
  myReservations: ReservationInfo[]
  // 我屏蔽的作者列表
  myBlockAuthors: string[]
  // 我屏蔽的新闻列表
  myBlockNewsList: string[]
  // 会员到期时间
  memExpireTime: number
}