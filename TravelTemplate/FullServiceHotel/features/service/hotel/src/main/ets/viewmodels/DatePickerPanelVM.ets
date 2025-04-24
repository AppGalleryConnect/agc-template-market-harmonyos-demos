import { promptAction } from '@kit.ArkUI';

const dateLabelMap: Map<number, string> = new Map([
  [0, '星期日'],
  [1, '星期一'],
  [2, '星期二'],
  [3, '星期三'],
  [4, '星期四'],
  [5, '星期五'],
  [6, '星期六'],
]);

@ObservedV2
export class DatePickerPanelVM {
  @Trace roomCount: number = 1;
  @Trace checkInDate: Date;
  @Trace checkOutDate: Date;
  @Trace today: Date = new Date();
  readonly MIN_ROOM_COUNT: number = 1;
  readonly MAX_ROOM_COUNT: number = 99;

  constructor() {
    this.checkInDate = new Date();
    this.checkOutDate = new Date();
    this.checkOutDate.setDate(this.today.getDate() + 1);
  }

  private static _instance: DatePickerPanelVM;

  public static get instance() {
    if (!DatePickerPanelVM._instance) {
      DatePickerPanelVM._instance = new DatePickerPanelVM();
    }
    return DatePickerPanelVM._instance;
  }

  @Computed
  public get totalDays() {
    let timeDiff: number = this.checkOutDate.getTime() - this.checkInDate.getTime();
    return Math.floor(timeDiff / (24 * 60 * 60 * 1000));
  }

  @Computed
  public get startDate() {
    return this.today;
  }

  @Computed
  public get endDate() {
    const endDate = new Date(this.today);
    endDate.setMonth(endDate.getMonth() + 1);
    return endDate;
  }

  public getDateMonth(date: Date) {
    return date.getMonth() + 1;
  }

  public handleConfirm(date: Date | Date[], callback: () => void) {
    let dates: Date[] = date as Date[];
    const curDate = new Date();
    if (
      dates[0].getFullYear() < curDate.getFullYear() ||
        dates[0].getMonth() < curDate.getMonth() ||
        dates[0].getMonth() === curDate.getMonth() && dates[0].getDate() < curDate.getDate()
    ) {
      promptAction.showToast({ message: '抵店日期不得小于当天，请重新选择' });
      return;
    }
    this.checkInDate = dates[0];
    this.checkOutDate = dates[1];
    callback();
  }

  public changeRoomCount(value: number, callback: () => void) {
    let preview: number = this.roomCount + value;
    if (preview >= this.MIN_ROOM_COUNT && preview <= this.MAX_ROOM_COUNT) {
      this.roomCount = preview;
      callback();
    }
  }

  public getDateLabel(date: Date) {
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  public getDateDescription(date: Date) {
    const today = new Date(this.today);
    today.setHours(0, 0, 0, 0);
    const yesterday = new Date(today);
    yesterday.setDate(today.getDate() + 1);
    const compareDate = new Date(date);
    compareDate.setHours(0, 0, 0, 0);

    if (compareDate.getTime() === today.getTime()) {
      return '今天';
    } else if (compareDate.getTime() === yesterday.getTime()) {
      return '明天';
    }
    const label = dateLabelMap.get(date.getDay());
    return label ?? '';
  }

  public resetRoomCount(){
    this.roomCount = 1;
  }
}
