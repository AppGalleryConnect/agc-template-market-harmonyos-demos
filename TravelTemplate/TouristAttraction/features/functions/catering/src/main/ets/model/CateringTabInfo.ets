import { CateringComponentBuilder } from '../components/CateringComponent';
import { AccommodationComponentBuilder } from '../components/AccommodationComponent';

export interface CateringTabBarData {
  id: CateringTabBarType;
  title: ResourceStr;
  component: WrappedBuilder<[]>
}

export enum CateringTabBarType {
  CATERING = 0,
  ACCOMMODATION = 1,
}

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