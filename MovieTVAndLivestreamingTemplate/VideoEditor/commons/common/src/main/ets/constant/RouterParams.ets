/**
 * 全局路由参数类型定义
 */
export interface HomePageParam {
  /** 指定首页 Tabs 的停留索引 */
  stayTabIndex?: number;
  /** 来源页面标识，例如 RouterMap.EXPORT_VIDEO_PAGE */
  source?: string;
}