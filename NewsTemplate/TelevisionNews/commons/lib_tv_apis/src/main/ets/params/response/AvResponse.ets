/**
 * 音视频内容-云侧接口响应模型
 */
export interface AvResponse {
  id: string
  title: string
  description: string
  isFollow: boolean
  coverUrl: string
  total: number
  section: AvSectionModel[]
}

/**
 * 视频节目单-云侧接口响应模型
 */
export interface VideoProgramResponse {
  programId: string
  title: string
  duration: number,
  updateTime: string
  isEnd: boolean
}

/**
 * 公众号-云侧接口响应模型
 */
export interface SubscribeResponse {
  subscribeName: string
  subscribeId: string
  subscribeDesc: string
  subscribeIcon: string
  subscribeWorks: string[]
}

export interface AvSectionModel {
  id: string
  title: string
  duration: number
  updateTime: string
  sectionUrl: string
  coverUrl: string
  needVip: boolean
}