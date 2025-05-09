export enum OrderTriggerMap {
  CREATE_COURSE_ORDER = 'create-course-order', // 课程订阅
  CANCEL_COURSE_ORDER = 'cancel-course-order', // 课程去订阅
  REQUEST_REFUND_COURSE_ORDER = 'request-refund-course-order', // 申请课程退款
  CANCEL_REFUND_COURSE_ORDER = 'cancel-refund-course-order', // 取消课程退款
  DELETE_COURSE_ORDER = 'delete-course-order', // 删除课程订单
  GET_ORDER_LIST = 'get-order-list', // 获取订单列表
  GET_ORDER_DETAIL = 'get-order-detail', // 获取订单详情
}

export enum OrderStatusMap {
  PENDING_PAYMENT = 1,
  CANCEL = 2,
  COMPLETE = 3,
  REFUND_IN_PROGRESS = 4,
  REFUNDED = 5,
}
