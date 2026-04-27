import { TValueType } from 'common'

/**
 * 页面跳转信息
 */
export interface NavPageInfo {
  /** 页面名称 */
  pageName: string
  /** 所在路由栈的名称 */
  routerName?: string
  /** 自定义参数 */
  param?: TValueType
  /** 动态注册, 自定义view/页面 */
  builder?: WrappedBuilder<[Object]>
  /** 回调事件 */
  onPop?: Callback<PopInfo>
}