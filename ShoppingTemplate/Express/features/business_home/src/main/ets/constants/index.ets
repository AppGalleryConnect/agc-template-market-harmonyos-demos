import { timeList } from 'module_base'
import { ITime } from '../types'

export const dayList: ITime[] = [
  {
    text: '今天',
    value: 1,
    timeList: timeList
  },
  {
    text: '明天',
    value: 2,
    timeList: timeList
  },
  {
    text: '后天',
    value: 3,
    timeList: timeList
  }
]

export function getTimeList(dayList: ITime[]): ITime[] {
  const data: ITime[] = []
  dayList.forEach((item) => {
    const temp: ITime = {
      text: item.text,
      value: item.value,
      timeList: item.timeList
    }
    data.push(temp)
  })
  const time = new Date().getHours()
  if (time < 8) {
    return data
  }

  if (time > 18) {
    return data.slice(1, 2)
  }

  const count = time - 8
  if (count < 10) {
    data[0].timeList = data[0].timeList.slice(count)
  } else {
    data.shift()
  }
  return data
}