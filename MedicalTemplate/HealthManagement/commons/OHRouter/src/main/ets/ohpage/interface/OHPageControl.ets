import { UserInfo } from 'common'

export interface OHPageControl {
  /** 页面id */
  id?: string
  aboutToAppear?: () => void
  aboutToDisappear?: () => void
  onPageShow?: () => void
  onPageHide?: () => void
  onBackPress?: () => void | boolean
  userInfoChange?: (userInfo : UserInfo) => void
}