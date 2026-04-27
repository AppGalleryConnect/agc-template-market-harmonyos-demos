import { CalendarUtil, DateModel, getMonthDate } from 'calendar_select';
import { RoomTypePrice } from 'type';

export function getRoomOrderAmount(priceList: RoomTypePrice[], startDate: DateModel, endDate: DateModel): number {
  let startDay = startDate.day;
  let endDay = endDate.day;
  let amount = 0;
  if (startDate.year === endDate.year && startDate.month === endDate.month) {
    for (let i = startDay; i < endDay; i++) {
      let priceItem = priceList.find((priceItem: RoomTypePrice) => priceItem.roomPriceDay ===
        `${startDate.year}-${CalendarUtil.formatDate(startDate.month)}-${CalendarUtil.formatDate(i)}`);
      amount += priceItem?.actualPrice ?? 0;
    }
  } else if ((startDate.year === endDate.year && startDate.month < endDate.month) || startDate.year < endDate.year) {
    let startMonthday = getMonthDate(startDate.year, startDate.month);
    for (let i = startDay; i < startMonthday.filter((item) => item !== 0).length; i++) {
      let priceItem = priceList.find((priceItem: RoomTypePrice) => priceItem.roomPriceDay ===
        `${startDate.year}-${CalendarUtil.formatDate(startDate.month)}-${CalendarUtil.formatDate(i)}`);
      amount += priceItem?.actualPrice ?? 0;
    }

    for (let i = 0; i < endDate.day; i++) {
      let priceItem = priceList.find((priceItem: RoomTypePrice) => priceItem.roomPriceDay ===
        `${startDate.year}-${CalendarUtil.formatDate(startDate.month)}-${CalendarUtil.formatDate(i)}`);
      amount += priceItem?.actualPrice ?? 0;
    }
  }

  return amount;
}