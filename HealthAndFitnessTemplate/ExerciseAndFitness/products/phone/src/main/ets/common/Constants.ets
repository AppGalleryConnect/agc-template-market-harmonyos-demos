import { RouterMap } from 'lib_common';

export interface TabBarItem {
  id: TabBarType;
  title: ResourceStr;
  activeIcon: Resource;
  defaultIcon: Resource;
}

export enum TabBarType {
  HOME = 0,
  COURSE,
  PLAN,
  MINE
}

export const TABS_INFO: TabBarItem[] = [
  {
    id: TabBarType.HOME,
    title: '首页',
    activeIcon: $r('sys.symbol.house_fill'),
    defaultIcon: $r('sys.symbol.house'),
  },
  {
    id: TabBarType.COURSE,
    title: '课程',
    activeIcon: $r('sys.symbol.resolution_video_fill'),
    defaultIcon: $r('sys.symbol.resolution_video'),
  },
  {
    id: TabBarType.PLAN,
    title: '计划',
    activeIcon: $r('sys.symbol.doc_text_badge_checkmark_fill'),
    defaultIcon: $r('sys.symbol.doc_text_badge_checkmark'),
  },
  {
    id: TabBarType.MINE,
    title: '我的',
    activeIcon: $r('sys.symbol.person_fill'),
    defaultIcon: $r('sys.symbol.person'),
  },
]

/**
 * 依赖登录的页面
 */
export const REQUIRE_LOGIN_PAGE_LIST: RouterMap[] = [
  RouterMap.MINE_MARK_PAGE,
  RouterMap.FEEDBACK_PAGE,
  RouterMap.MINE_HISTORY_PAGE,
  RouterMap.VIP_PAGE,
  RouterMap.RECORD_PAGE,
  RouterMap.COURSE_PAGE_PLAN
];

export const agreePrivacyKey: string = 'isAgreePrivacy';

export const SOURCE_FORM_CARD: string = 'FormCard';

export const skipGuide: string = 'isSkipGuide';

export class PhoneConstants {
  static readonly LEFT_TAB_BAR_WIDTH: number = 96;
  static readonly LEFT_TAB_BAR_ITEM_HEIGHT: number = 100;
  static readonly BOTTOM_TAB_BAR_HEIGHT: number = 52;
}
