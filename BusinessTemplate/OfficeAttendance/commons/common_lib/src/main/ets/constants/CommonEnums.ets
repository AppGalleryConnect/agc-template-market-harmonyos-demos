export enum AppStorageMap {
  HUAWEI_ACCOUNT = 'huaweiAccount',
  USER_INFO = 'userInfo',
}

export enum RouterMap {
  // 我的-修改个人信息
  MINE_PROFILE_EDIT = 'ProfileEditPage',
  // 我的-修改个人信息
  SELECT_DATE = 'CalenderView',

  EDIT_AGENCY_TASK = 'editAgencyTaskDialog',

  MAIN_ENTRY = 'mainEntry',

  ABOUT = 'about',

  USER_INFO = 'userInfo'
}

export enum DialogMap {
  BIND_PHONE_DIALOG = 'BindPhoneDialog',
  NEW_AGENCY_TASK = 'newAgencyTaskDialog',
  TIME_SELECTOR = 'timeSelector',
  AGENCY_TASK_CALENDER = 'agencyTaskCalender',
  //编辑待办
  EDIT_AGENCY_TASK = 'editAgencyTaskDialog',
  CHECK_IN_HISTORY = 'checkinHistoryDialog',
  CHECK_IN_SETTINGS = 'checkinSettingsDialog',
  ACCOUNT_VERIFICATION = 'accountVerificationDialog',
  NEW_SCHEDULE = 'newScheduleDialog',
  EDIT_SCHEDULE = 'editScheduleDialog',
  SCHEDULE_DETAIL = 'scheduleDetailDialog',
}

export class RecurrenceFrequency {
  //	每年重复。
  public static YEARLY = 0;
  //	每月重复。
  public static MONTHLY = 1;
  //每周重复。
  public static WEEKLY = 2;
  //	每天重复。
  public static DAILY = 3
}

export class TabIndex {
  public static CHECKIN: number = 0;
  public static AGENCY: number = 1;
}