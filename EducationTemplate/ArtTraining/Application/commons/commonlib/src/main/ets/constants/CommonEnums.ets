export enum AppStorageMap {
  HUAWEI_ACCOUNT = 'huaweiAccount',
  USER_INFO = 'userInfo',
  STORE_PHONE = 'storePhone',
}

export enum TabsIndexMap {
  HOME,
  COURSES_LIST,
  CHECK_IN,
  MINE,
}

export enum RouterMap {
  // 路由拦截-绑定手机号页面
  BIND_PHONE = 'BindPhonePage',

  // 首页 - 关于我们
  HOME_STORE_INTRODUCTION = 'StoreIntroductionPage',
  // 首页 - 附近门店
  HOME_LOCATION = 'LocationPage',

  // 课程中心 - 课程详情
  COURSE_DETAIL = 'CourseDetailPage',
  // 课程中心 - 课程预下单
  COURSE_PREPAY = 'CoursePrepayPage',
  // 课程中心 - 下单完成页
  COURSE_SUBMITTED = 'OrderSubmittedPage',

  // 打卡活动 - 活动详情
  ACTIVITY_INTRODUCTION = 'ActivityIntroductionPage',
  // 打卡活动 - 打卡列表
  ACTIVITY_TASK = 'TaskCheckInPage',
  // 打卡活动 - 提交打卡
  ACTIVITY_SUBMIT = 'SubmitCheckInPage',
  // 打卡活动 - 提交打卡
  ACTIVITY_FULL_SCREEN_MEDIA = 'FullScreenMediaPage',

  // 我的 - 修改个人信息
  MINE_INFO_EDIT = 'UserInfoEditPage',
  // 我的 - 我的订单
  MINE_ORDER_LIST = 'MyOrderPage',
  // 我的 - 订单详情
  MINE_ORDER_DETAIL = 'OrderDetailPage',
  // 我的 - 已购课程
  MINE_MY_COURSES = 'MyCoursePage',
  // 我的 - 课程表
  MINE_TIMETABLE = 'TimetablePage',
  // 我的 - 我的打卡
  MINE_MY_CHECK_IN = 'MyCheckInPage',
  // 我的 - 学员证
  MINE_STUDENT_ID_CARD = 'MyIDCardPage',
  // 我的 - 关于我们
  MINE_ABOUT_US = 'AboutUsPage',
  // 我的 - 隐私声明
  MINE_PRIVACY = 'PrivacyPage',
}

export enum DialogMap {
  COMMON_CONFIRM = 'CommonConfirmDialog',
  CONTACT_CUSTOM_SERVICE = 'ContactCustomerServiceDialog',
}

export enum CourseTypeMap {
  ALL,
  ONLINE,
  OFFLINE,
}

export enum CoursePaymentMap {
  OFFLINE,
  ONLINE,
}

export enum CourseExpireTypeMap {
  LONG_TERM = 0, // 长期有效
  LIMITED_TIME = 1, // 限时有效
}

export enum CourseStatusMap {
  NOT_STARTED = 1, // 未上课
  IN_PROGRESS = 2, // 在读中
  COMPLETED = 3, // 已结课
}

export enum TaskCheckInStatus {
  NOT_STARTED = 1, //未打卡
  COMPLETED = 2, // 已打卡
}

export enum OrderTabsMap {
  ALL = 0,
  PENDING_PAYMENT = 1,
  COMPLETED = 2,
  AFTER_SALE = 3,
}

export enum OrderStatusMap {
  PENDING_PAYMENT = 1,
  CANCEL = 2,
  COMPLETE = 3,
  REFUND_IN_PROGRESS = 4,
  REFUNDED = 5,
}
