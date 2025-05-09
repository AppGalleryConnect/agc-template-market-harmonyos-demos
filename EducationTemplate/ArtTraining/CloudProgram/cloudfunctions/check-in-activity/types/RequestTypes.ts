export interface BaseReq {
  userId: string;
}

export interface GetActivityDetailReq extends BaseReq {
  activityId: number;
}

export interface CheckInActivityOrderReq extends BaseReq {
  activityId: number;
}

export interface GetUserCheckInRecordListReq extends BaseReq {
  activityId: number;
}

export interface SubmitCheckInReq extends BaseReq {
  taskId: number;
  activityId: number;
  textDetail?: string;
  pictureDetail?: string[];
  audioDetail?: string[];
  videoDetail?: string[];
}

export interface GetUserCheckInRecordListReq extends BaseReq {
  activityId: number;
}
