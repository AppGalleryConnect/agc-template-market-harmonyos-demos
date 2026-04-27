import { SystemUtil } from 'common';
import { TouristInfo } from 'types';
import { https, TouristRequest } from 'network';
import { mapTouristInfo } from '../mapper/Index';

@ObservedV2
export class TouristVM {
  @Trace touristList: TouristInfo[] = [];
  public static _instance: TouristVM;

  public static get instance() {
    if (!TouristVM._instance) {
      TouristVM._instance = new TouristVM();
    }
    return TouristVM._instance;
  }

  getTourists() {
    https.getTouristList().then((res) => {
      if (res.code === 0) {
        this.touristList = mapTouristInfo(res.data);
      }
    });
  }

  editItemInfo(item: TouristInfo,
    isEdit: boolean) {
    let params: TouristRequest = {
      id: isEdit ? item.id : SystemUtil.doRandBySync(2),
      name: item?.name,
      phone: item?.phone,
      cardType: item?.cardType,
      cardNo: item?.cardNo,
      isChecked: item?.isChecked,
    };

    if (isEdit) {
      https.modifyTourist(params).then((res) => {
        if (res.code === 0) {
          let index = this.touristList.findIndex((item) => item.id === params.id);
          // 更新游客信息
          this.touristList[index].name = params.name;
          this.touristList[index].phone = params.phone;
          this.touristList[index].cardType = params.cardType;
          this.touristList[index].cardNo = params.cardNo;
          this.touristList[index].isChecked = params.isChecked;
        }
      });
    } else {
      https.createTourist(params).then((res) => {
        if (res.code === 0) {
          item.id = params.id;
          this.touristList.push(item);
        }
      });
    }
  }

  deleteItemInfo(id: string) {
    https.deleteTourist(id).then((res) => {
      if (res.code === 0) {
        this.touristList = this.touristList.filter(item => item.id !== id);
      }
    });
  }
}