import dayjs from 'dayjs';

export function getVipDuration(dateType: string){
  const today = dayjs();
  let res:string = ''
  const oneMonthLater = today.add(1, 'month');
  const halfYearLater = today.add(6, 'month');
  if(dateType === 'month') {
    res = oneMonthLater.format('YYYY-MM-DD')
  }
  if(dateType === 'halfYear') {
    res = halfYearLater.format('YYYY-MM-DD')
  }
  if(dateType === 'perpetual') {
    res = '终生会员'
  }
  return res
}