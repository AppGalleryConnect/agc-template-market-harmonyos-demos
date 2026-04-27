import { AppStorageV2 } from '@kit.ArkUI';
import { TouristInfo, TouristList } from 'types';

@ObservedV2
export class TouristUtil {
  private static touristList: TouristList = AppStorageV2.connect(TouristList, 'touristInfo', () => new TouristList())!;

  public static getTouristList() {
    return TouristUtil.touristList
  }

  public static addTourist(tourist: TouristInfo) {
    TouristUtil.touristList.push(tourist)
  }
}