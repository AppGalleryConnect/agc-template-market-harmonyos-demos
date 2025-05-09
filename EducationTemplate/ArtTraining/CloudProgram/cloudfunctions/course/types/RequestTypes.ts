export interface BaseReq {
  userId: string;
}

/**
 * @type 课程类型，0：线上，1：线下
 */
export interface GetCourseListReq extends BaseReq {
  type?: number;
  keyword?: string;
}

export interface GetCourseDetailReq extends BaseReq {
  courseId: number;
}

export interface GetCourseListOrderedReq extends BaseReq {
  courseStatus: number;
}

export interface CourseOrderReq extends BaseReq {
  courseId: number;
  paymentMethod: number;
  student: string;
  phone: string;
  price: number;
  remark: string;
}

export interface GetOrderListReq extends BaseReq {
  orderStatus: number[];
}

export interface GetOrderDetailReq extends BaseReq {
  orderNo: string;
}
