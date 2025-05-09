/**
 * @keyword:关键字
 * @fromPage: 分页
 * @pageSize: 数据容量，不设置时默认为全量数据
 */
export interface PageQueryReq {
  keyword?: string;
  fromPage?: number;
  pageSize?: number;
}

/**
 * @type 课程类型，0：线上，1：线下
 */
export interface GetCourseListReq extends PageQueryReq {
  type?: number;
}

export interface GetCourseDetailReq {
  courseId: number;
}

export interface CourseOrderReq {
  courseId: number;
  paymentMethod: number;
  student: string;
  phone: string;
  price: number;
  remark: string;
}

export interface GetOrderListReq extends PageQueryReq {
  orderStatus: number[];
}

export interface GetOrderDetailReq{
  orderNo: string;
}

export interface GetCourseListOrderedReq extends PageQueryReq {
  courseStatus: number;
}

export interface GetCheckInActivityReq {
  activityId: number;
}

export interface CheckInTaskOrderReq {
  activityId: number;
}

export interface GetUserCheckInRecordListReq extends PageQueryReq {
  activityId: number;
}