@ObservedV2
export class RecordingList {
  constructor(startData: string, startTime: string, endTime: string, startLocation: string, endLocation: string,
    price: number, checked: boolean) {
    this.startData = startData
    this.startTime = startTime
    this.endTime = endTime
    this.startLocation = startLocation
    this.endLocation = endLocation
    this.price = price
    this.checked = checked
  }

  @Trace startData: string = ''
  @Trace startTime: string = ''
  @Trace endTime: string = ''
  @Trace startLocation: string = ''
  @Trace endLocation: string = ''
  @Trace price: number = 0
  @Trace checked: boolean = false
}


export const threeDays: RecordingList[] = [
  new RecordingList('2015/03/19',
    '07:30:04',
    '08:29:32',
    '北京西',
    '故宫',
    6, false)
]

export const oneMonth: RecordingList[] = [
  new RecordingList('2015/03/19',
    '07:30:04',
    '08:29:32',
    '北京西',
    '故宫',
    6, false),
  new RecordingList('2015/03/19',
    '07:30:04',
    '08:29:32',
    '北京西',
    '故宫',
    6, false)
]

export const threeMonths: RecordingList[] = [
  new RecordingList('2015/03/19',
    '07:30:04',
    '08:29:32',
    '北京西',
    '故宫',
    6, false),
  new RecordingList('2015/03/19',
    '07:30:04',
    '08:29:32',
    '北京西',
    '故宫',
    6, false),
  new RecordingList('2015/03/19',
    '07:30:04',
    '08:29:32',
    '北京西',
    '故宫',
    6, false)
]

export const recordingList: RecordingList[][] = [threeDays, oneMonth, threeMonths]

export function allCancel(){
  recordingList.forEach((item,index)=>{
    item.forEach((value,index)=>{
      value.checked = false
    })
  }, (item: string, index: number) => item + index)
}