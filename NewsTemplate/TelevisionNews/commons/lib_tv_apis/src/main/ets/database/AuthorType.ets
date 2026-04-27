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
  // 订阅号
  subscribe: string[]
}