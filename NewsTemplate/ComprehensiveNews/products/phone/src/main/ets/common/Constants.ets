import { RouterMap, TabBarType } from 'lib_common';

export interface TabBarItem {
  id: TabBarType;
  title: ResourceStr;
  activeIcon: ResourceStr;
}

export const TABS_INFO: TabBarItem[] = [
  {
    id: TabBarType.HOME,
    title: '首页',
    activeIcon: $r('app.media.ic_tab_home'),
  },
  {
    id: TabBarType.VIDEO,
    title: '视频',
    activeIcon: $r('app.media.ic_tab_video'),
  },
  {
    id: TabBarType.COMMUNITY,
    title: '互动',
    activeIcon: $r('app.media.ic_tab_interaction'),
  },
  {
    id: TabBarType.MINE,
    title: '我的',
    activeIcon: $r('app.media.ic_tab_mine'),
  },
]

/**
 * 依赖登录的页面
 */
export const REQUIRE_LOGIN_PAGE_LIST: RouterMap[] = [
  RouterMap.MINE_COMMENT_PAGE,
  RouterMap.MINE_MARK_PAGE,
  RouterMap.MINE_LIKE_PAGE,
  RouterMap.FEEDBACK_SUBMIT_PAGE,
  RouterMap.PUBLISH_POST_PAGE,
  RouterMap.MINE_MSG_IM_CHAT,
  RouterMap.SETTING_SUBSCRIBE,
];

export const agreePrivacyKey: string = 'isAgreePrivacy';

export const SOURCE_FORM_CARD: string = 'FormCard';

export const NEWS_DETAIL_PAGE: string = 'NewsDetailPage';
