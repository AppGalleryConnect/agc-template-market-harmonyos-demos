import { DialogMap, RouterMap } from './CommonEnums';

export class CommonConstants {
  // 需要登录才能访问的页面
  public static readonly NEED_LOGIN_PAGE: (RouterMap | DialogMap)[] = [
    RouterMap.COURSE_PREPAY,
    RouterMap.ACTIVITY_TASK,
    RouterMap.ACTIVITY_SUBMIT,
    RouterMap.MINE_INFO_EDIT,
    RouterMap.MINE_ORDER_LIST,
    RouterMap.MINE_ORDER_DETAIL,
    RouterMap.MINE_MY_COURSES,
    RouterMap.MINE_TIMETABLE,
    RouterMap.MINE_MY_CHECK_IN,
    RouterMap.MINE_STUDENT_ID_CARD,
  ];
}
