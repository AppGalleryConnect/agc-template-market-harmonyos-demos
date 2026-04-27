@Observed
export class CalendarOption {
  @Track start: DateModel | undefined = undefined
  @Track end: DateModel | undefined = undefined
  @Track night: number = 0
  @Track isShowPrice: boolean = false
  @Track priceList: Price[] = []
}

@Observed
export class DateModel {
  @Track day: number;
  @Track week: number;
  @Track month: number;
  @Track year: number;

  constructor(day: number, week: number, month: number, year: number) {
    this.day = day;
    this.week = week;
    this.month = month;
    this.year = year;
  }

  set(day: number, month: number, year: number) {
    this.day = day;
    this.month = month;
    this.year = year;
  }
}

export interface SelectBgColor {
  index: number;
  bgColor: Resource;
}

export interface Price {
  date: string,
  price: number
}


export interface DateItemModel {
  curMonthStartDate: Date,
  curMonthEndDate: Date,
  nextMonthStartDate: Date,
  nextMonthEndDate: Date,
}

@Observed
export class Month {
  month: string = '';
  num: number = 0;
  days: number[];
  daysInfo: DayInfo[] = [];

  constructor(month: string = '', num: number = 0, days: number[] = [], daysInfo: DayInfo[] = []) {
    this.month = month;
    this.days = days;
    this.num = num;
    this.daysInfo = daysInfo;
  }
}

@Observed
export class DayInfo {
  day: number = 0;
  price: number = 0;

  constructor(day = 0, price = 0) {
    this.day = day;
    this.price = price;
  }
}

export class MonthDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private dataArray: Month[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): Month {
    return this.dataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    });
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    });
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    });
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    });
  }

  public addData(index: number, data: Month): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: Month | Month[]): void {
    if (Array.isArray(data)) {
      this.dataArray.push(...data);
    } else {
      this.dataArray.push(data);
    }
    this.notifyDataAdd(this.dataArray.length - 1);
  }
}
