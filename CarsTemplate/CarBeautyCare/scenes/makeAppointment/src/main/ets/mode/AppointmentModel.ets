import { ShopCardModel, ShopModel, SHOP_NANJING } from '@ohos_agcit/car_beauty_care_shop';
import { VehicleModel } from '@ohos_agcit/car_beauty_care_garage'

// 一个店铺的预约数据信息
export interface SelectedData {
  date: DateModel;
  time: TimeModel;
  card: ShopCardModel;
  type: BTN_TYPE; //预约类型：保养、维修等
  id?: string;
  licenseNumber?: string;
}

@ObservedV2
export class DateModel {
  @Trace label: string;
  @Trace date: string;
  @Trace checked: boolean;

  constructor(label: string, date: string, checked: boolean) {
    this.label = label;
    this.date = date;
    this.checked = checked;
  }
}

@ObservedV2
export class TimeModel {
  @Trace label: string;
  @Trace time: number;
  @Trace disabled: boolean; //时间是否不可用
  @Trace checked: boolean;

  constructor(label: string, time: number, disabled: boolean, checked: boolean) {
    this.label = label;
    this.time = time;
    this.disabled = disabled;
    this.checked = checked;
  }
}


export const daysOfWeek = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

export const timeOfDay: TimeModel[] = [
  new TimeModel('08:00', 8, false, false),
  new TimeModel('09:00', 9, false, false),
  new TimeModel('10:00', 10, false, false),
  new TimeModel('11:00', 11, false, false),
  new TimeModel('12:00', 12, false, false),
  new TimeModel('13:00', 13, false, false),
  new TimeModel('14:00', 14, false, false),
  new TimeModel('15:00', 15, false, false),
  new TimeModel('16:00', 16, false, false),
  new TimeModel('17:00', 17, false, false),
  new TimeModel('18:00', 18, false, false),
];

export enum TIME_NAME {
  TODAY = '今天',
  TOMORROW = '明天'
}

export enum BTN_TYPE {
  MAINTENANCE = '保养',
  REPAIRS = '维修',
  TIRE = '轮胎',
  BEAUTY = '美容'
}


export const getDate: (index: number) => DateModel = (index: number): DateModel => {
  const now = new Date(); //当前日期对象
  const next = new Date(now); //创建新的Date对象，用于计算目标日期
  next.setDate(now.getDate() + index); //计算目标日期
  const nextDate = next.getDate().toString();
  const nextDayOfWeek = next.getDay().toString();
  const month = String(next.getMonth() + 1);
  let label: string;
  if (index === 0) {
    label = TIME_NAME.TODAY;
  } else if (index === 1) {
    label = TIME_NAME.TOMORROW;
  } else {
    label = daysOfWeek[nextDayOfWeek];
  }
  const dt: DateModel = new DateModel(label, `${month}.${nextDate}`, index === 0 ? true : false);
  return dt;
};


