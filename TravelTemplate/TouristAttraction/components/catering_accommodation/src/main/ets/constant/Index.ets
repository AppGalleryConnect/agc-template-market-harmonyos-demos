import { AccommodationComponentBuilder } from '../component/AccommodationComponent';
import { CateringComponentBuilder } from '../component/CateringComponent';
import { CateringTabBarData, CateringTabBarType } from '../model/Index';

export const CATERING_TABS_INFO: CateringTabBarData[] = [
  {
    id: CateringTabBarType.CATERING,
    title: '餐饮',
    component: wrapBuilder(CateringComponentBuilder)
  },
  {
    id: CateringTabBarType.ACCOMMODATION,
    title: '住宿',
    component: wrapBuilder(AccommodationComponentBuilder)
  }
]