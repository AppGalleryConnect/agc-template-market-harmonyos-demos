export enum ResponseStatusCode {
  SUCCESS = 0,
  BAD_REQUEST = 400,
}


export enum RequestUrl {
  SCHEDULE_CONFIG = '/course/scheduleConfig',
  QUERY_DAY_COURSE = '/course/queryDayCourse',
  QUERY_ALL_COURSE = '/course/queryAllCourse',
  CLASS_SIGN_IN = '/course/signIn',
  USER_BIND_PHONE = '/user/bindPhone',
  USER_GET_INFO = '/user/getInfo',
  USER_UPDATE_NICKNAME = '/user/updateNickname',
}