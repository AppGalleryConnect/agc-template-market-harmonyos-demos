import { ActivityBookingStates } from '../../constants/CommonContants';
import { ActivityModel } from './ActivityModel';

@ObservedV2
export class ActivityBookingRecordModel{
  // 活动报名记录id
  id: number | null;

  // 用户id
  userId: string| null;

  // 预约的姓名
  userName: string| null;

  // 预约的电话
  phone: string| null;

  // 预约状态
  state: number| null;

  // 报名活动时间
  bookingTime: Date| null;

  // 取消活动时间
  cancelTime: Date | null;

  // 是否加入日程
  addToCalender: boolean = false;

  activity: ActivityModel | null = ActivityModel.createEmptyActivity();

  constructor(id: number | null, userId: string| null, userName: string| null, phone: string| null,
    state: number| null, bookingTime: Date| null, cancelTime: Date| null, activity: ActivityModel | null) {
    this.id = id;
    this.userId = userId;
    this.userName = userName;
    this.phone = phone;
    this.state = state;
    this.bookingTime = bookingTime;
    this.cancelTime = cancelTime;
    this.activity = activity;
  }

  static createRecWithUserInfo(userName: string, phone: string, activity: ActivityModel){
    return new ActivityBookingRecordModel(null, '',userName,phone,1,new Date,null, activity);
  }

  static createRec(activity: ActivityModel) : ActivityBookingRecordModel {
    let  rec = ActivityBookingRecordModel.createEmptyRec();
    rec.state = ActivityBookingStates.BOOKING;
    rec.activity = activity;
    return rec;
  }

  static createEmptyRec() : ActivityBookingRecordModel {
    return new ActivityBookingRecordModel(null, null, null, null, null,
      null, null, ActivityModel.createEmptyActivity());
  }
}