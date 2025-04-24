import { WEEK_LABELS } from './Constant';

export class DayModel {
  date: Date;
  dateDesc: string;
  weekDesc: ResourceStr;

  constructor(date: Date, index: number) {
    this.date = date;
    this.dateDesc = `${date.getMonth() + 1}-${date.getDate().toString().padStart(2, '0')}`;
    if (index === 0) {
      this.weekDesc = WEEK_LABELS[7];
    } else if (index === 1) {
      this.weekDesc = WEEK_LABELS[8];
    } else {
      this.weekDesc = WEEK_LABELS[date.getDay()];
    }
  }
}

/**
 * 获取从当天开始的一周
 */
export const get7Days = (): DayModel[] => {
  const total = 7;
  const today = new Date();
  let todayDate = today.getDate();
  const days: DayModel[] = [...new Array(total)].map((item: number, index: number) => {
    const curDate = today.setDate(todayDate);
    todayDate++;
    return new DayModel(new Date(curDate), index);
  });
  return days;
};

/**
 * 获取对应日期可以选择的时间
 */
export const getAllowTimes = (startTime: number, endTime: number): string[] => {
  const date = new Date(startTime);
  date.setSeconds(0);
  let hours = date.getHours();
  let minutes = date.getMinutes();

  if (minutes < 30) {
    date.setMinutes(30);
  } else {
    date.setHours(hours + 1);
    date.setMinutes(0);
  }

  const times: string[] = [];
  while (date.getTime() <= endTime) {
    times.push(`${date.getHours()}:${date.getMinutes().toString().padStart(2, '0')}`);
    date.setMinutes(date.getMinutes() + 30);
  }

  return times;
};
