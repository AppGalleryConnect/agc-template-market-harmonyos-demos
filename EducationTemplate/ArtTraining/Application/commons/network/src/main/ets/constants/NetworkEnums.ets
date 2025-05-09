export enum RequestUrl {
  BIND_PHONE = 'bind-phone',
  UNBIND_PHONE = 'unbind-phone',
  USER_GET_INFO = 'get-user-info',
  USER_UPDATE_INFO = 'update-user-info',
  GET_STORE_CONFIG = 'get-store-config',

  GET_COURSE_DETAIL = 'get-course-detail', // 获取课程详情
  GET_COURSE_LIST = 'get-course-list', // 获取课程列表
  CREATE_COURSE_ORDER = 'create-course-order', // 课程订阅
  CANCEL_COURSE_ORDER = 'cancel-course-order', // 课程去订阅
  REQUEST_REFUND_COURSE_ORDER = 'request-refund-course-order', // 申请课程退款
  CANCEL_REFUND_COURSE_ORDER = 'cancel-refund-course-order', // 取消课程退款
  DELETE_COURSE_ORDER = 'delete-course-order', // 删除课程订单
  GET_ORDER_LIST = 'get-order-list', // 获取订单列表
  GET_ORDER_DETAIL = 'get-order-detail', // 获取订单详情
  GET_COURSE_LIST_ORDERED = 'get-course-list-ordered', // 获取已订阅的课程列表

  GET_CHECKIN_ACTIVITY_DETAIL = 'get-check-in-activity-detail', // 获取打卡任务详情
  GET_CHECKIN_ACTIVITY_LIST = 'get-check-in-activity-list', // 获取打卡任务列表
  CREATE_CHECKIN_ACTIVITY_ORDER = 'create-check-in-activity-order', // 打卡任务订阅
  CANCEL_CHECKIN_ACTIVITY_ORDER = 'cancel-check-in-activity-order', // 打卡任务去订阅
  GET_CHECKIN_ACTIVITY_LIST_ORDERED = 'get-check-in-activity-list-ordered', // 获取已订阅的打卡任务列表

  COMMIT_USER_CHECKIN = 'commit-user-check-in', // 用户打卡提交
  GET_USER_CHECKIN_RECORD_LIST = 'get-user-checkin-record-list', // 获取用户打卡记录列表
}

export enum CloudFuncMap {
  ACCOUNT = 'account-management',
  COURSE = 'course',
  CHECK_IN_ACTIVITY = 'check-in-activity',
  ORDER = 'order',
}