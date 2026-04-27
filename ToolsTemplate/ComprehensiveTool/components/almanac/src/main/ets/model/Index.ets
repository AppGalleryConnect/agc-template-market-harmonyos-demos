import CalendarVM from '../viewmodel/CalendarVM';

export class LuckyDays {
  solarDate: Date | string = '2025-05-10T00:00:00.000Z';
  lunarDate: string = '二〇二五年四月十三';
  ganZhiYear: string = '乙巳';
  ganZhiDay: string = '己卯';
  ganZhiMonth: string = '辛巳';
  weekday: string = '星期六';
  daysFromNow: number = 2;
  forwardOrBack?: CALCULATION_TYPE = CALCULATION_TYPE.FORWARD;
}

export enum CALCULATION_TYPE {
  BACKWARD = 'backward',
  FORWARD = 'forward',
}

@ObservedV2
export class AreaType {
  @Trace top: number = 0;
  @Trace bottom: number = 0;
}

export class LunarInfo {
  year: string = ''
  month: string = ''
  day: string = ''
  weekday: string = ''
}

export class CustomTabsInfo {
  icon: string = ''
  iconSel: string = ''
  name: string = ''
  id: string = ''
}

export class YiJiSetDate {
  name: string = ''
  des: string = '古时临近婚期前一个月，男方还要备酒、蓝布和金银 钗环交给媒人送到女方家，谓之“裁衣”。现指逛街买 新衣服。'

  constructor(name?: string) {
    this.name = name ?? ''
  }
}

/**
 * 抛出句柄
 */
export class CalendarController {
  public static vm: CalendarVM = CalendarVM.instance;

  public getTodayYiJi() {
    CalendarController.vm.getTodayYiJi();
  }

  public setSelectDate(date: Date) {
    CalendarController.vm.changeDate(date);
  }
}