@ObservedV2
export class PlanePageVM {
  @Trace searchContent: string = ''
  @Trace chooseStatus: number = 0
  @Trace returnCity: string = '北京'
  @Trace returnCity1: string = '上海'
  @Trace placeName: string = ''
  @Trace locationPermission: boolean = false
  // 弹框id，用于关闭
  dialogId: number = 0;
}

export enum ChooseStatus {
  Aircraft = 0, //机票
  Train = 1, //火车票
  Bus = 2, //汽车票
  OneWay = 3, //单程
  Return = 4 //往返
}