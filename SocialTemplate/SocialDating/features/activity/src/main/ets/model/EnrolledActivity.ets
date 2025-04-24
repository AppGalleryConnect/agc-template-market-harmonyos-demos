import { ActivityInfo } from './ActivityInfo';

export class EnrolledActivity {
  id: number | null = null;
  uid: number | null = null;
  enrollTime: number | null = null;
  status: number | null = null;
  activity: ActivityInfo | null = null;

  constructor(id: number | null, uid: number | null, enrollTime: number | null, status: number | null,
    activity: ActivityInfo | null) {
    this.id = id;
    this.uid = uid;
    this.enrollTime = enrollTime;
    this.status = status;
    this.activity = activity;
  }

  static STATUS_TO_PAY = '待付款';
  static STATUS_ENROLLED_SUCCESS = '已报名';
  static STATUS_FINISHED = '已结束';
  static STATUS_CANCELED = '已取消';

  static getStatusDisplayInfo(status: number): StatusDisplay {
    if (status === EnrollActivityStatus.ToPay) {
      return new StatusDisplay(status, EnrolledActivity.STATUS_TO_PAY, $r('app.color.button_background_color'),
        '#FFFFFF');
    } else if (status === EnrollActivityStatus.EnrolledSuccess) {
      return new StatusDisplay(status, EnrolledActivity.STATUS_ENROLLED_SUCCESS,
        $r('app.color.activity_status_normal'), $r('app.color.text_font_color_black'));
    } else if (status === EnrollActivityStatus.Finished) {
      return new StatusDisplay(status, EnrolledActivity.STATUS_FINISHED,
        $r('app.color.activity_status_normal'), $r('app.color.text_font_color_black'));
    } else {
      return new StatusDisplay(status, EnrolledActivity.STATUS_CANCELED,
        $r('app.color.activity_status_canceled'), $r('app.color.text_font_color_black'));
    }
  }
}

export class StatusDisplay {
  statusValue: number;
  statusDisplayValue: string;
  statusButtonColor: string | Resource;
  statusValueColor: string | Resource;

  constructor(statusValue: number, statusDisplayValue: string, statusButtonColor: string | Resource,
    statusValueColor: string | Resource) {
    this.statusValue = statusValue;
    this.statusDisplayValue = statusDisplayValue;
    this.statusButtonColor = statusButtonColor;
    this.statusValueColor = statusValueColor;
  }
}

export enum EnrollActivityStatus {
  ToPay,
  EnrolledSuccess,
  Finished,
  Canceled
}