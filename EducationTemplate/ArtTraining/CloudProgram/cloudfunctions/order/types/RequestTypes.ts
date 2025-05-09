export interface BaseReq {
  userId: string;
}

export interface CourseOrderReq extends BaseReq {
  courseId: number;
  paymentMethod: number;
  student: string;
  phone: string;
  price: number;
  remark: string;
}

export interface OrderNoReq extends BaseReq {
  orderNo: string;
}

export interface GetOrderListReq extends BaseReq {
  orderStatus: number[];
}

export interface GetOrderDetailReq extends BaseReq {
  orderNo: string;
}
