import { SearchImgType } from '../common/model';

@ObservedV2
export class HotelDetailsPageVM {
  @Trace hotelClassificationList: SearchImgType[] =
    [{ img: $r('app.media.ic_renovation'), text: '装修' }, { img: $r('app.media.ic_laundry'), text: '洗衣房' },
      { img: $r('app.media.ic_smoke'), text: '无烟楼层' }, { img: $r('app.media.ic_family'), text: '家庭房' },
      { img: $r('app.media.ic_customization'), text: '全屋暖气' }];
}