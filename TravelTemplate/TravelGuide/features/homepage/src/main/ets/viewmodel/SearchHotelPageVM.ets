import { HotelModel, MockService } from 'common_travel_guide'


@ObservedV2
export class SearchHotelPageVM {
  @Trace isDelete: boolean = false

  @Trace hotelList: HotelModel[] = MockService.hotelResult
  @Trace searchHotelList: HotelModel[] = []
}