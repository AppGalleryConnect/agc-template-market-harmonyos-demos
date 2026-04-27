import { HotelModel, MockService, MockTourListService, TourModel } from 'common_travel_guide';
import { HotSearchType, SearchImgType } from '../common/model';

@ObservedV2
export class SearchPageVM {
  @Trace isDeleteStatus: boolean = false
  @Trace allClassificationList: SearchImgType[] =
    [{ img: $r('app.media.ic_search_trainTicket'), text: '火车票' },
      { img: $r('app.media.ic_search_airTicket'), text: '机票' },
      { img: $r('app.media.ic_search_hotel'), text: '酒店' },
      { img: $r('app.media.ic_search_attraction'), text: '景点' },];
  @Trace hotSearchList: HotSearchType[] = [
    { name: '香格里拉', rating: '4.5', distance: '9.7公里' },
    { name: '大明湖公园', rating: '4.6', distance: '8.2公里' },
    { name: '千佛山风景区', rating: '4.4', distance: '12.5公里' },
    { name: '泉城广场', rating: '4.3', distance: '10.1公里' },
    { name: '黑虎泉', rating: '4.2', distance: '9.9公里' },
    { name: '五龙潭公园', rating: '4.0', distance: '9.5公里' },
    { name: '红叶谷生态文化旅游区', rating: '4.7', distance: '35.0公里' },
    { name: '济南动物园', rating: '4.1', distance: '15.3公里' },
    { name: '山东省博物馆', rating: '4.8', distance: '14.2公里' },
    { name: '曲水亭街', rating: '4.4', distance: '9.8公里' },
  ]
  @Trace hotTourList: HotSearchType[] = [
    { name: '玉龙雪山', rating: '4.1', distance: '10.5公里' },
    { name: '解放阁', rating: '4.3', distance: '10.0公里' },
    { name: '灵岩寺旅游区', rating: '4.6', distance: '60.5公里' },
    { name: '济南植物园', rating: '4.2', distance: '28.7公里' },
    { name: '洪家楼教堂', rating: '4.5', distance: '13.8公里' },
    { name: '环城公园', rating: '4.0', distance: '9.6公里' },
    { name: '九如山瀑布群', rating: '4.8', distance: '55.0公里' },
    { name: '济南野生动物世界', rating: '4.7', distance: '50.2公里' },
    { name: '百脉泉公园', rating: '4.3', distance: '45.8公里' },
    { name: '芙蓉街', rating: '4.2', distance: '9.9公里' },
  ]
  @Trace hotHotelList: HotSearchType[] = [
    { name: '南京南站希尔顿大酒店', rating: '4.0', distance: '18.2公里' },
    { name: '济南泉城大酒店', rating: '4.3', distance: '8.9公里' },
    { name: '济南东方大厦', rating: '4.2', distance: '9.3公里' },
    { name: '济南珍珠泉宾馆', rating: '4.4', distance: '10.0公里' },
    { name: '济南华能大厦', rating: '4.1', distance: '11.6公里' },
    { name: '济南银座颐庭大酒店', rating: '4.5', distance: '12.8公里' },
    { name: '济南舜耕山庄', rating: '4.6', distance: '13.5公里' },
    { name: '济南玉泉森信大酒店', rating: '4.3', distance: '8.4公里' },
    { name: '济南丽天大酒店', rating: '4.2', distance: '9.1公里' },
    { name: '济南山东大厦', rating: '4.7', distance: '14.0公里' }
  ]
  @Trace hotelList: HotelModel[] = MockService.hotelResult
  @Trace mockTourList: TourModel[] = MockTourListService.tourResult
  @Trace searchList: HotelModel[] = []
}