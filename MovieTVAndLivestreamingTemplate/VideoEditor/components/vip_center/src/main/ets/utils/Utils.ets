import dayjs from 'dayjs';

export function getVipDuration(dateType: string) {
  const today = dayjs();
  let res: string = ''
  const oneMonthLater = today.add(1, 'month');
  const oneYearLater = today.add(12, 'month');
  if (dateType === 'month') {
    res = oneMonthLater.format('YYYY-MM-DD') + '到期'
  }
  if (dateType === 'year') {
    res = oneYearLater.format('YYYY-MM-DD') + '到期'
  }
  if (dateType === 'once' || dateType === '') {
    res = '一次会员'
  }
  if (dateType === 'perpetual') {
    res = '终生会员'
  }
  return res
}