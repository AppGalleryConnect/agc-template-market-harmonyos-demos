import { DateIndex, TimeFormat } from '../model/Time';

export  function isVisibility(dateIndex: DateIndex, timeFormat?: TimeFormat): Visibility {
  let format: DateIndex[] = [DateIndex.DAY, DateIndex.HOURS, DateIndex.MINUTES, DateIndex.SECOND];
  return (dateIndex <= format[timeFormat ?? TimeFormat.MINUTES]) ? Visibility.Visible : Visibility.None;
}