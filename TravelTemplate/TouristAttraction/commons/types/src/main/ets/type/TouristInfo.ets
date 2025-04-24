@ObservedV2
export class TouristInfo {
  @Trace id: string = ''
  @Trace name: string = ''
  @Trace phone: string = ''
  @Trace cardType: number = 0
  @Trace cardNo: string = ''
  @Trace isChecked: boolean = false

  constructor(id: string = '') {
    this.id = id
  }
}

export class TouristList extends Array<TouristInfo> {
}