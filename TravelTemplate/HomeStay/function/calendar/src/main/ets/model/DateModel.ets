/*
 * 设置项的数据类
 */
export class DateModel {
  day: number;
  week: number;
  month: number;
  year: number;

  constructor(day: number, week: number, month: number, year: number) {
    this.day = day;
    this.week = week;
    this.month = month;
    this.year = year;
  }

  set(day: number,  month: number, year: number){
    this.day = day;
    this.month = month;
    this.year = year;
  }
}

export interface SelectBgColor {
  index: number;
  bgColor: Resource;
}

export interface Price{
  date: string,
  price: number
}


export interface DateItemModel {
  curMonthStartDate: Date,
  curMonthEndDate: Date,
  nextMonthStartDate: Date,
  nextMonthEndDate: Date,
}