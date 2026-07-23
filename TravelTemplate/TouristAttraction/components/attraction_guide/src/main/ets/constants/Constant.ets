import { AccommodationInfo, AttractionInfo, AttractionUtil, CateringInfo } from 'module_base';
import { Guide, LocationType } from '../model/GuideInfo';
import { Permissions } from '@kit.AbilityKit';

export const GUIDE_TABS_INFO = [{
  id: 0,
  title: '景点',
  icon: $r('sys.symbol.tropicaltrees_and_sand_1'),
  type: LocationType.ATTRACTION,
  data: AttractionUtil.getAttraction().attractions,
} as Guide<AttractionInfo>,
  {
    id: 1,
    title: '餐饮',
    icon: $r('sys.symbol.spoon_chopsticks_fill'),
    type: LocationType.CATERING,
    data: AppStorage.get('cateringList')!,
  } as Guide<CateringInfo>,
  {
    id: 2,
    title: '酒店',
    icon: $r('sys.symbol.hotel'),
    type: LocationType.ACCOMMODATION,
    data: AppStorage.get('accommodationList')!,
  } as Guide<AccommodationInfo>,
];

export const HEIGHT_LOW_SMALL: number = 120
export const HEIGHT_LOW_MIDDLE: number = 200
export const HEIGHT_MIDDLE: number = 638
export const LOCATION_PERMISSION: Permissions[] = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];
// 用户授权成功
export const  USER_GRANT_SUCCESS = 0