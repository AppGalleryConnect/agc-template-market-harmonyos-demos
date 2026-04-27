/**
 * @fileType: common
 * @zhName: 页面控制接口
 */
import { UserInfo } from 'common'

export interface OHPageControl {
  /** 页面id */
  id?: string
  aboutToAppear?: () => void
  aboutToDisappear?: () => void
  onPageShow?: () => void
  onPageHide?: () => void
  onBackPress?: () => boolean
  userInfoChange?: (userInfo: UserInfo) => void
}