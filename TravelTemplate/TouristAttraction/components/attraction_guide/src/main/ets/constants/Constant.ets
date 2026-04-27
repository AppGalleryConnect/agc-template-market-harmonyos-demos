import { AccommodationInfo, AttractionInfo, AttractionUtil, CateringInfo, ToiletInfo } from 'module_base';
import { Guide, LocationType } from '../model/GuideInfo'

export const GUIDE_TABS_INFO = [{
  id: 0,
  title: '景点',
  activeIcon: $r('app.media.guide_scenic'),
  defaultIcon: $r('app.media.guide_scenic_default'),
  icon: $r('app.media.icon_scenic'),
  type: LocationType.ATTRACTION,
  data: AttractionUtil.getAttraction().attractions,
} as Guide<AttractionInfo>,
  {
    id: 1,
    title: '餐饮',
    activeIcon: $r('app.media.guide_catering'),
    defaultIcon: $r('app.media.guide_catering_default'),
    icon: $r('app.media.icon_catering'),
    type: LocationType.CATERING,
    data: AppStorage.get('cateringList')!,
  } as Guide<CateringInfo>,
  {
    id: 2,
    title: '住宿',
    activeIcon: $r('app.media.guide_accommodation'),
    defaultIcon: $r('app.media.guide_accommodation_default'),
    icon: $r('app.media.icon_accommodation'),
    type: LocationType.ACCOMMODATION,
    data: AppStorage.get('accommodationList')!,
  } as Guide<AccommodationInfo>,
  {
    id: 3,
    title: '卫生间',
    activeIcon: $r('app.media.guide_toilets'),
    icon: $r('app.media.icon_toilet'),
    defaultIcon: $r('app.media.guide_toilets_default'),
    type: LocationType.TOILETS,
    data: AppStorage.get('toiletList')!,
  } as Guide<ToiletInfo>,
];