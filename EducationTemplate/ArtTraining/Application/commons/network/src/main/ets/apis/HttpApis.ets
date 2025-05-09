import { AccountUtil, CheckInActivity, CheckInRecord, CourseInfo, OrderInfo, StoreConfig, UserInfo } from 'commonlib';
import { CloudFuncMap, RequestUrl } from '../constants/NetworkEnums';
import request from '../models/CloudHttpModel';
import {
  CheckInTaskOrderReq,
  CourseOrderReq,
  GetCheckInActivityReq,
  GetCourseDetailReq,
  GetOrderListReq,
  GetCourseListReq,
  GetUserCheckInRecordListReq,
  PageQueryReq,
  GetCourseListOrderedReq,
  GetOrderDetailReq,
} from '../types/RequestTypes';
import {
  BaseResp,
  BaseResponse,
  GetCheckInActivityListRsp,
  GetCourseListResp,
  GetOrderListResp,
  GetUserCheckInRecordListRsp,
} from '../types/ResponseTypes';

@ObservedV2
class HttpApi {
  @Trace private _accountInfo = AccountUtil.getAccountInfo();

  public bindPhone(authCode: string, createMock: boolean = false): Promise<BaseResp<UserInfo>> {
    return request.call({
      url: RequestUrl.BIND_PHONE,
      cloudFuncName: CloudFuncMap.ACCOUNT,
      data: {
        trigger: RequestUrl.BIND_PHONE,
        userId: this._accountInfo.openID,
        authCode,
        createMock,
      },
    });
  }

  public unBindPhone(): Promise<BaseResponse> {
    return request.call({
      url: RequestUrl.UNBIND_PHONE,
      cloudFuncName: CloudFuncMap.ACCOUNT,
      data: {
        trigger: RequestUrl.UNBIND_PHONE,
        userId: this._accountInfo.openID,
      },
    });
  }

  public getUserInfo(): Promise<BaseResp<UserInfo>> {
    return request.call({
      url: RequestUrl.USER_GET_INFO,
      cloudFuncName: CloudFuncMap.ACCOUNT,
      data: {
        trigger: RequestUrl.USER_GET_INFO,
        userId: this._accountInfo.openID,
      },
    });
  }

  public updateUserInfo(data: UserInfo): Promise<BaseResp<UserInfo>> {
    return request.call({
      url: RequestUrl.USER_UPDATE_INFO,
      cloudFuncName: CloudFuncMap.ACCOUNT,
      data: {
        trigger: RequestUrl.USER_UPDATE_INFO,
        userId: this._accountInfo.openID,
        avatar:data.avatar,
        nickname:data.nickname,
        wechat:data.wechat,
        birthday:data.birthday,
      },
    });
  }

  public getStoreConfig(): Promise<BaseResp<StoreConfig>> {
    return request.call({
      url: RequestUrl.GET_STORE_CONFIG,
      cloudFuncName: CloudFuncMap.COURSE,
      data: {
        userId: this._accountInfo.openID,
      },
    });
  }

  public getCourseList(data?: GetCourseListReq): Promise<BaseResp<GetCourseListResp>> {
    return request.call({
      url: RequestUrl.GET_COURSE_LIST,
      cloudFuncName: CloudFuncMap.COURSE,
      data: {
        trigger: RequestUrl.GET_COURSE_LIST,
        userId: this._accountInfo.openID,
        type: data?.type,
        keyword: data?.keyword,
      },
    });
  }

  public getCourseDetail(data: GetCourseDetailReq): Promise<BaseResp<CourseInfo>> {
    return request.call({
      url: RequestUrl.GET_COURSE_DETAIL,
      cloudFuncName: CloudFuncMap.COURSE,
      data: {
        trigger: RequestUrl.GET_COURSE_DETAIL,
        userId: this._accountInfo.openID,
        courseId: data.courseId,
      },
    });
  }

  public getCourseListOrdered(data: GetCourseListOrderedReq): Promise<BaseResp<GetCourseListResp>> {
    return request.call({
      url: RequestUrl.GET_COURSE_LIST_ORDERED,
      cloudFuncName: CloudFuncMap.COURSE,
      data: {
        trigger: RequestUrl.GET_COURSE_LIST_ORDERED,
        userId: this._accountInfo.openID,
        courseStatus: data.courseStatus,
      },
    });
  }

  public createCourseOrder(data: CourseOrderReq): Promise<BaseResp<OrderInfo>> {
    return request.call({
      url: RequestUrl.CREATE_COURSE_ORDER,
      cloudFuncName: CloudFuncMap.ORDER,
      data: {
        trigger: RequestUrl.CREATE_COURSE_ORDER,
        userId: this._accountInfo.openID,
        courseId: data.courseId,
        paymentMethod: data.paymentMethod,
        student: data.student,
        phone: data.phone,
        price: data.price,
        remark: data.remark,
      },
    });
  }

  public cancelCourseOrder(data: GetOrderDetailReq): Promise<BaseResponse> {
    return request.call({
      url: RequestUrl.CANCEL_COURSE_ORDER,
      cloudFuncName: CloudFuncMap.ORDER,
      data: {
        trigger: RequestUrl.CANCEL_COURSE_ORDER,
        orderNo: data.orderNo,
        userId: this._accountInfo.openID,
      },
    });
  }

  public requestRefundCourseOrder(data: GetOrderDetailReq): Promise<BaseResponse> {
    return request.call({
      url: RequestUrl.REQUEST_REFUND_COURSE_ORDER,
      cloudFuncName: CloudFuncMap.ORDER,
      data: {
        trigger: RequestUrl.REQUEST_REFUND_COURSE_ORDER,
        orderNo: data.orderNo,
        userId: this._accountInfo.openID,
      },
    });
  }

  public cancelRefundCourseOrder(data: GetOrderDetailReq): Promise<BaseResponse> {
    return request.call({
      url: RequestUrl.CANCEL_REFUND_COURSE_ORDER,
      cloudFuncName: CloudFuncMap.ORDER,
      data: {
        trigger: RequestUrl.CANCEL_REFUND_COURSE_ORDER,
        orderNo: data.orderNo,
        userId: this._accountInfo.openID,
      },
    });
  }

  public deleteCourseOrder(data: GetOrderDetailReq): Promise<BaseResponse> {
    return request.call({
      url: RequestUrl.DELETE_COURSE_ORDER,
      cloudFuncName: CloudFuncMap.ORDER,
      data: {
        trigger: RequestUrl.DELETE_COURSE_ORDER,
        orderNo: data.orderNo,
        userId: this._accountInfo.openID,
      },
    });
  }

  public getOrderList(data: GetOrderListReq): Promise<BaseResp<GetOrderListResp>> {
    return request.call({
      url: RequestUrl.GET_ORDER_LIST,
      cloudFuncName: CloudFuncMap.ORDER,
      data: {
        trigger: RequestUrl.GET_ORDER_LIST,
        orderStatus: data.orderStatus,
        userId: this._accountInfo.openID,
      },
    });
  }

  public getOrderDetail(data: GetOrderDetailReq): Promise<BaseResp<OrderInfo>> {
    return request.call({
      url: RequestUrl.GET_ORDER_DETAIL,
      cloudFuncName: CloudFuncMap.ORDER,
      data: {
        trigger: RequestUrl.GET_ORDER_DETAIL,
        orderNo: data.orderNo,
        userId: this._accountInfo.openID,
      },
    });
  }

  public getCheckInActivityList(): Promise<BaseResp<GetCheckInActivityListRsp>> {
    return request.call({
      url: RequestUrl.GET_CHECKIN_ACTIVITY_LIST,
      cloudFuncName: CloudFuncMap.CHECK_IN_ACTIVITY,
      data: {
        trigger: RequestUrl.GET_CHECKIN_ACTIVITY_LIST,
        userId: this._accountInfo.openID,
      },
    });
  }

  public getCheckInActivityDetail(data: GetCheckInActivityReq): Promise<BaseResp<CheckInActivity>> {
    return request.call({
      url: RequestUrl.GET_CHECKIN_ACTIVITY_DETAIL,
      cloudFuncName: CloudFuncMap.CHECK_IN_ACTIVITY,
      data: {
        trigger: RequestUrl.GET_CHECKIN_ACTIVITY_DETAIL,
        userId: this._accountInfo.openID,
        activityId: data.activityId,
      },
    });
  }

  public createCheckInActivityOrder(data: CheckInTaskOrderReq): Promise<BaseResponse> {
    return request.call({
      url: RequestUrl.CREATE_CHECKIN_ACTIVITY_ORDER,
      cloudFuncName: CloudFuncMap.CHECK_IN_ACTIVITY,
      data: {
        trigger: RequestUrl.CREATE_CHECKIN_ACTIVITY_ORDER,
        userId: this._accountInfo.openID,
        activityId: data.activityId,
      },
    });
  }

  public cancelCheckInActivityOrder(data: CheckInTaskOrderReq): Promise<BaseResponse> {
    return request.call({
      url: RequestUrl.CANCEL_CHECKIN_ACTIVITY_ORDER,
      cloudFuncName: CloudFuncMap.CHECK_IN_ACTIVITY,
      data: {
        trigger: RequestUrl.CANCEL_CHECKIN_ACTIVITY_ORDER,
        userId: this._accountInfo.openID,
        activityId: data.activityId,
      },
    });
  }

  public getCheckInActivityListOrdered(data?: PageQueryReq): Promise<BaseResp<GetCheckInActivityListRsp>> {
    return request.call({
      url: RequestUrl.GET_CHECKIN_ACTIVITY_LIST_ORDERED,
      cloudFuncName: CloudFuncMap.CHECK_IN_ACTIVITY,
      data: {
        trigger: RequestUrl.GET_CHECKIN_ACTIVITY_LIST_ORDERED,
        userId: this._accountInfo.openID,
        fromPage:data?.fromPage,
        pageSize:data?.pageSize,
      },
    });
  }

  public commitUserCheckIn(data: CheckInRecord): Promise<BaseResponse> {
    return request.call({
      url: RequestUrl.COMMIT_USER_CHECKIN,
      cloudFuncName: CloudFuncMap.CHECK_IN_ACTIVITY,
      data: {
        trigger: RequestUrl.COMMIT_USER_CHECKIN,
        userId: this._accountInfo.openID,
        taskId:data.taskId,
        activityId:data.activityId,
        textDetail:data.textDetail,
        pictureDetail:data.pictureDetail,
        audioDetail:data.audioDetail,
        videoDetail:data.videoDetail,
        createTime:data.createTime,
      },
    });
  }

  public getUserCheckInRecordList(data: GetUserCheckInRecordListReq): Promise<BaseResp<GetUserCheckInRecordListRsp>> {
    return request.call({
      url: RequestUrl.GET_USER_CHECKIN_RECORD_LIST,
      cloudFuncName: CloudFuncMap.CHECK_IN_ACTIVITY,
      data: {
        trigger: RequestUrl.GET_USER_CHECKIN_RECORD_LIST,
        userId: this._accountInfo.openID,
        activityId: data.activityId,
      },
    });
  }
}

const https = new HttpApi();

export { https };