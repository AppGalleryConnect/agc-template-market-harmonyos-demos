export enum CheckInTriggerMap {
  GET_CHECKIN_ACTIVITY_DETAIL = 'get-check-in-activity-detail', // 获取打卡任务详情
  GET_CHECKIN_ACTIVITY_LIST = 'get-check-in-activity-list', // 获取打卡任务列表
  CREATE_CHECKIN_ACTIVITY_ORDER = 'create-check-in-activity-order', // 打卡任务订阅
  CANCEL_CHECKIN_ACTIVITY_ORDER = 'cancel-check-in-activity-order', // 打卡任务去订阅
  GET_CHECKIN_ACTIVITY_LIST_ORDERED = 'get-check-in-activity-list-ordered', // 获取已订阅的打卡任务列表

  COMMIT_USER_CHECKIN = 'commit-user-check-in', // 用户打卡提交
  GET_USER_CHECKIN_RECORD_LIST = 'get-user-checkin-record-list', // 获取用户打卡记录列表
}
