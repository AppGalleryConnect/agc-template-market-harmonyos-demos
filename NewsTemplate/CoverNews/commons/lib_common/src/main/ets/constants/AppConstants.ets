import { RouterMap } from './RouterMap';

/**
 * 应用常量
 */
export class AppConstants {
  /**
   * 应用根Navigation的ID
   */
  public static readonly NAVIGATION_ID: string = 'navigationId';
  /**
   * 支持分享的页面
   */
  static readonly SHARE_PAGES: string[] = [
    RouterMap.NEWS_DETAIL_PAGE,
  ]
}