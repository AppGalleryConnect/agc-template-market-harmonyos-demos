/**
 * 作者-云侧接口响应模型
 */
export interface AuthorResponse {
  // 作者id
  authorId: string
  //作者昵称
  authorNickName: string
  // 作者icon
  authorIcon: string
  //作者简介
  authorDesc: string
  // 作者ip
  authorIp: string
  // 订阅号
  subscribe?: string[]
  // 手机号
  authorPhone?: string
}