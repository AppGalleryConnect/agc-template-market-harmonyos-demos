import dayjs from 'dayjs';
import { cityListMap } from '../constants/Constants';
import { LimitsList } from '../model/Model';

export function getCityLimits(location: string, date: Date): LimitsList[] {
  let target = cityListMap.find(item => item.city === location)
  const today = dayjs(date);
  const tomorrow = today.add(1, 'day');
  let weekday1 = dayjs(date).format('dddd').toLowerCase()
  let weekday2 = dayjs(tomorrow).format('dddd').toLowerCase()
  return [{
    date: today.format('M月D日'),
    limits: target?.limits[weekday1] ?? [2, 7]  as number[],
  },
    {
      date: tomorrow.format('M月D日'),
      limits: target?.limits[weekday2]?? [3, 8]  as number[],
    }]
}
