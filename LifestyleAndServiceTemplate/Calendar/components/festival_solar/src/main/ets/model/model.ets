export class SolarInfo {
  solarDate: string = '';
  lunarDate: string = '';
  solarTerm: string = '';
}

export interface PublicHolidayInfo {
  day: string
  name: string
  holiday: string
  totalRest: number
  weekDay: string
  adjustWorkDays?: string
}

export interface HolidayInfo {
  solarDate: string;
  lunarDate: string;
  holidayName: string[];
  daysUntil: number;
  month:string;
  day:string
}

