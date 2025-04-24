import { GetTouristListResp } from 'network';
import { TouristInfo } from 'types';

export function mapTouristInfo(getTouristListResp: GetTouristListResp) {
  let touristList: TouristInfo[] = [];
  getTouristListResp.forEach((item => {
    let tourist: TouristInfo = new TouristInfo();
    tourist.id = item.id;
    tourist.name = item.name;
    tourist.phone = item.phone;
    tourist.cardType = item.cardType;
    tourist.cardNo = item.cardNo;
    tourist.isChecked = item.isChecked;
    touristList.push(tourist);
  }));
  return touristList;
}