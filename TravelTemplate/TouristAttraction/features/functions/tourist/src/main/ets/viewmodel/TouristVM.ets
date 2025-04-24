import { shippingAddress } from '@kit.AccountKit';
import { promptAction } from '@kit.ArkUI';
import { doRandBySync, Logger, verifyCardNo, verifyPhoneNo } from 'common';
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
        Logger.info('count of tourist ' + this.touristList);
      }
    });
  }

  validate(tourist: TouristInfo) {
    if (!verifyPhoneNo(tourist.phone)) {
      promptAction.showToast({ message: '请正确填写游客手机号码', duration: 1000 });
      return false;
    } else if (!verifyCardNo(tourist.cardNo)) {
      promptAction.showToast({ message: '请正确填写游客身份证号', duration: 1000 });
      return false;
    } else if (!tourist.name.length || !tourist.phone.length || !tourist.cardNo.length) {
      promptAction.showToast({ message: '请正确填写游客信息', duration: 1000 });
      return false;
    }
    return true;
  }

  editItemInfo(item: TouristInfo,
    isEdit: boolean) {
    let params: TouristRequest = {
      id: isEdit ? item.id : doRandBySync(2),
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
          Logger.info('create tourist success');
        }
      });
    } else {
      https.createTourist(params).then((res) => {
        if (res.code === 0) {
          item.id = params.id;
          this.touristList.push(item);
          Logger.info('create tourist success');
        }
      });
    }
  }

  deleteItemInfo(id: string) {
    https.deleteTourist(id).then((res) => {
      if (res.code === 0) {
        this.touristList = this.touristList.filter(item => item.id !== id);
        Logger.info('delete tourist success');
      }
    });
  }

  getCheckedTourists() {
    let checkedItems = this.touristList.filter((item) => item.isChecked);
    return checkedItems;
  }

  mapDistrict(systemAddress: shippingAddress.AddressInfo): string {
    return systemAddress.provinceName + `省` + systemAddress.cityName + systemAddress.districtName +
    systemAddress.streetName;
  }
}