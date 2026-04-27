/** 页面配置类*/
import { UserInfo } from 'common'
import { OHPageControl } from '../interface/OHPageControl'

@ObservedV2
export class OHPageConfig {
  /** 页面id，非pageId */
  id?: string
  aboutToAppear?: () => void
  aboutToDisappear?: () => void
  onPageShow?: () => void
  onPageHide?: () => void
  onBackPress?: () => boolean
  userInfoChange?: (userInfo : UserInfo) => void

  constructor(params?: OHPageControl) {
    /** 页面id */
    this.id = params?.id ?? ''
    this.aboutToAppear = params?.aboutToAppear
    this.aboutToDisappear = params?.aboutToDisappear
    this.onPageShow = params?.onPageShow
    this.onPageHide = params?.onPageHide
    this.onBackPress = params?.onBackPress
    this.userInfoChange = params?.userInfoChange
  }
}