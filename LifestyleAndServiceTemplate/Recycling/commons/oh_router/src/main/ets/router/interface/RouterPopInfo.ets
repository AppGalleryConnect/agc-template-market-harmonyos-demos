/**
 * 页面返回参数信息
 */
export interface RouterPopInfo {
  /** 页面名称 */
  pageName?: string
  /** 页面所在路由栈的名称 */
  routerName?: string
  /** 返回参数**/
  popData?: Object
}