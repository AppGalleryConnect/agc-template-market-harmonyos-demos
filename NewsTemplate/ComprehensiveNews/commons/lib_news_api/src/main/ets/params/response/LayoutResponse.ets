import { NavInfo } from '../base/BaseModel'
import { AuthorResponse } from './AuthorResponse'
import { NewsResponse } from './NewsResponse'

export class AuthorInfo implements AuthorResponse {
  // 作者id
  authorId: string = ''
  //作者昵称
  authorNickName: string = ''
  // 作者icon
  authorIcon: string = ''
  //作者简介
  authorDesc: string = ''
  // 作者ip
  authorIp: string = ''
  // 关注的人数
  watchersCount: number = 0
  // 粉丝数量
  followersCount: number = 0
  // 获赞数量
  likeNum: number = 0
}

export interface FlexLayoutModel {
  navInfo: NavInfo
  articles: string[]
  extraInfo: Record<string, string | boolean | Record<string, string | boolean>[]>
}

@ObservedV2
export class AbstractRequestListData {
  abstract: string = ''
  list: RequestListData[] = [];
}

@ObservedV2
export class RequestListData<T = NewsResponse> {
  navInfo: NavInfo = new NavInfo()
  @Trace articles: T[] = []
  extraInfo: Record<string, string | number | boolean | Record<string, string | boolean>[]> = {}
}

export class LayoutStyle {
  backgroundColor: string = ''
  borderRadius: number = 0
  space: number = 0
  paddingLeft: number | string = 0
  paddingRight: number | string = 0
  paddingBottom: number | string = 0
  paddingTop: number | string = 0
}