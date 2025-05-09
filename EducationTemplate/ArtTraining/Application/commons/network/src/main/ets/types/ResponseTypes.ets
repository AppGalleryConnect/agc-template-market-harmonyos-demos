import {
  CheckInRecord,
  CheckInActivity,
  CourseInfo,
  OrderInfo,
  StoreInfo,
  SwiperItem,
} from 'commonlib';

export interface BaseRet {
  code: number;
  msg: string;
}

export interface BaseResponse {
  ret: BaseRet;
}

export interface BaseResp<T> {
  ret: BaseRet;
  result: T;
}

export interface GetStoreConfigResp extends BaseResponse {
  banners: SwiperItem[];
  storeInfo: StoreInfo;
  courseList: CourseInfo[];
}

export interface GetCourseListResp {
  totalCount: number;
  returnCount: number;
  courseList: CourseInfo[];
}


export interface GetOrderListResp {
  totalCount: number;
  returnCount: number;
  orderList: OrderInfo[];
}

export interface GetCheckInActivityListRsp {
  totalCount: number;
  returnCount: number;
  list: CheckInActivity[];
}


export interface GetUserCheckInRecordListRsp {
  totalCount: number;
  returnCount: number;
  list: CheckInRecord[];
}

export interface CheckInTaskItem {
  taskName: string; // 打卡任务名称
  taskId: number;
  taskDetail: string; // 打卡任务描述
  taskStatus: number; // 1未打卡 2已打卡
}