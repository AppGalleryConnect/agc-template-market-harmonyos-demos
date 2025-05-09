import { CheckInActivity, CheckInRecord, CourseInfo, OrderInfo, StoreConfig, UserInfo } from 'commonlib';
import {
  CheckInTaskOrderReq,
  CourseOrderReq,
  GetCheckInActivityReq,
  GetCourseDetailReq,
  GetOrderListReq,
  GetCourseListReq,
  GetUserCheckInRecordListReq,
  GetCourseListOrderedReq,
  GetOrderDetailReq,
} from '../types/RequestTypes';
import {
  BaseResp,
  BaseResponse,
  BaseRet,
  GetCheckInActivityListRsp,
  GetCourseListResp,
  GetOrderListResp,
  GetUserCheckInRecordListRsp,
} from '../types/ResponseTypes';
import { CourseDatasetMock } from './CourseDatasetMock';
import { CheckInActivityDatasetMock } from './CheckInActivityDatasetMock';
import { CheckInRecordDatasetMock } from './CheckInRecordDatasetMock';
import { StoreConfigMock } from './StoreConfigMock';
import { OrderDatasetMock } from './OrderDatasetMock';

const SUCCESS_RET: BaseRet = {
  code: 0,
  msg: '',
};

class HttpApiMock {
  private static _userInfo: UserInfo = {
    phone: '12300005678',
    nickname: '虚拟用户',
    avatar: '',
    studentID: '1741162744587',
    wechat: '',
    birthday: '',
  };

  public bindPhone(): Promise<BaseResponse> {
    const resp: BaseResponse = {
      ret: SUCCESS_RET,
    };
    return Promise.resolve(resp);
  }

  public unBindPhone(): Promise<BaseResponse> {
    const resp: BaseResponse = {
      ret: SUCCESS_RET,
    };
    return Promise.resolve(resp);
  }

  public getUserInfo(): Promise<BaseResp<UserInfo>> {
    const resp: BaseResp<UserInfo> = {
      ret: SUCCESS_RET,
      result: HttpApiMock._userInfo,
    };
    return Promise.resolve(resp);
  }

  public getStoreConfig(): Promise<BaseResp<StoreConfig>> {
    const res: BaseResp<StoreConfig> = {
      ret: SUCCESS_RET,
      result: {
        banners: StoreConfigMock.banners,
        storeInfo: StoreConfigMock.storeInfo,
        courseList: CourseDatasetMock.getCourseList(),
      },

    };
    return Promise.resolve(res);
  }

  public getCourseDetail(data: GetCourseDetailReq): Promise<BaseResp<CourseInfo>> {
    const course = CourseDatasetMock.getCourseDetail(data.courseId);
    const res: BaseResp<CourseInfo> = {
      ret: SUCCESS_RET,
      result: course,
    };
    return Promise.resolve(res);
  }

  public getCourseList(data?: GetCourseListReq): Promise<BaseResp<GetCourseListResp>> {
    const courseList = CourseDatasetMock.getCourseList(data?.type, data?.keyword);
    const res: BaseResp<GetCourseListResp> = {
      ret: SUCCESS_RET,
      result: {
        totalCount: 3,
        returnCount: 3,
        courseList,
      },
    };
    return Promise.resolve(res);
  }

  public createCourseOrder(data: CourseOrderReq): Promise<BaseResp<OrderInfo>> {
    const detail = OrderDatasetMock.createCourseOrder(data) as OrderInfo;
    const res: BaseResp<OrderInfo> = {
      ret: SUCCESS_RET,
      result: detail,
    };
    return Promise.resolve(res);
  }

  public cancelCourseOrder(orderNo: string): Promise<BaseResponse> {
    OrderDatasetMock.cancelCourseOrder(orderNo);
    const res: BaseResponse = {
      ret: SUCCESS_RET,
    };
    return Promise.resolve(res);
  }

  public getOrderList(data: GetOrderListReq): Promise<BaseResp<GetOrderListResp>> {
    const orderList = OrderDatasetMock.getOrderList(data.orderStatus);
    const res: BaseResp<GetOrderListResp> = {
      ret: SUCCESS_RET,
      result: {
        totalCount: orderList.length,
        returnCount: orderList.length,
        orderList,
      },
    };
    return Promise.resolve(res);
  }

  public getOrderDetail(data: GetOrderDetailReq): Promise<BaseResp<OrderInfo>> {
    const detail = OrderDatasetMock.getOrderDetail(data.orderNo);
    const res: BaseResp<OrderInfo> = {
      ret: SUCCESS_RET,
      result: detail,
    };
    return Promise.resolve(res);
  }

  public getCourseListOrdered(data: GetCourseListOrderedReq): Promise<BaseResp<GetCourseListResp>> {
    const courseList = CourseDatasetMock.getCourseListOrdered(data.courseStatus);
    const res: BaseResp<GetCourseListResp> = {
      ret: SUCCESS_RET,
      result: {
        totalCount: courseList.length,
        returnCount: courseList.length,
        courseList,
      },
    };
    return Promise.resolve(res);
  }

  public getCheckInActivityList(): Promise<BaseResp<GetCheckInActivityListRsp>> {
    const activityList = CheckInActivityDatasetMock.getActivityList();
    const res: BaseResp<GetCheckInActivityListRsp> = {
      ret: SUCCESS_RET,
      result: {
        returnCount: activityList.length,
        totalCount: activityList.length,
        list: activityList,
      },
    };
    return Promise.resolve(res);
  }

  public getCheckInActivityDetail(data: GetCheckInActivityReq): Promise<BaseResp<CheckInActivity>> {
    const task = CheckInActivityDatasetMock.getActivityDetail(data.activityId);
    const res: BaseResp<CheckInActivity> = {
      ret: SUCCESS_RET,
      result: task,
    };
    return Promise.resolve(res);
  }

  public createCheckInActivityOrder(data: CheckInTaskOrderReq): Promise<BaseResponse> {
    CheckInActivityDatasetMock.createActivityOrder(data.activityId);
    const res: BaseResponse = {
      ret: SUCCESS_RET,
    };
    return Promise.resolve(res);
  }

  public cancelCheckInActivityOrder(data: CheckInTaskOrderReq): Promise<BaseResponse> {
    CheckInActivityDatasetMock.createActivityOrder(data.activityId);
    const res: BaseResponse = {
      ret: SUCCESS_RET,
    };
    return Promise.resolve(res);
  }

  public getCheckInActivityListOrdered(): Promise<BaseResp<GetCheckInActivityListRsp>> {
    const activityList = CheckInActivityDatasetMock.getActivityListOrdered();
    const res: BaseResp<GetCheckInActivityListRsp> = {
      ret: SUCCESS_RET,
      result: {
        returnCount: activityList.length,
        totalCount: activityList.length,
        list: activityList,
      },
    };
    return Promise.resolve(res);
  }

  public commitUserCheckIn(data: CheckInRecord): Promise<BaseResponse> {
    CheckInRecordDatasetMock.commitUserCheckIn(data);
    const res: BaseResponse = {
      ret: SUCCESS_RET,
    };
    return Promise.resolve(res);
  }

  public getUserCheckInRecordList(data: GetUserCheckInRecordListReq): Promise<BaseResp<GetUserCheckInRecordListRsp>> {
    const recordList = CheckInRecordDatasetMock.getUserCheckInRecordList(data.activityId);
    const res: BaseResp<GetUserCheckInRecordListRsp> = {
      ret: SUCCESS_RET,
      result:{
        totalCount: recordList.length,
        returnCount: recordList.length,
        list: recordList,
      },
    };
    return Promise.resolve(res);
  }
}

const httpsMock = new HttpApiMock();

export { httpsMock };
