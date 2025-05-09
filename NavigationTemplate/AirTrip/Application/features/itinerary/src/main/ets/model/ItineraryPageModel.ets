export enum ItineraryStatus {
  UPCOMING_TRIP = '1',
  COMPLETED_TRIP = '2'
}

interface FunctionResultRet {
  code: number
  desc: string
}

@ObservedV2
export class ItineraryTabItem {
  label: string = ''
  @Trace count: number = 0
  @Trace status: string = ItineraryStatus.UPCOMING_TRIP

  constructor(label: string, count: number, status: string) {
    this.label = label
    this.count = count
    this.status = status
  }
}
