export interface CheckInHistoryDataItem {
  day: string;
  dayOfWeek: number;
  details: CheckInHistoryDetailDataItem[]
}

export interface CheckInHistoryDetailDataItem {
  time: string;
  location: string;
}

export interface CheckInDetailRecord {
  day: string;
  dayOfWeek: number;
  time: string;
  location: string;
}