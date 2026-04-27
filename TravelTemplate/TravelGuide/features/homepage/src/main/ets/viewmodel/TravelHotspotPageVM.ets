import { travelHotspotList, TravelHotspotItem } from '../common/mock/TravelHotspotMockData'

@ObservedV2
export class TravelHotspotPageVM {
  @Trace travelHotspotList: TravelHotspotItem[] = travelHotspotList
}



