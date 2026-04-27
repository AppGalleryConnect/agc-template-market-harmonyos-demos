import { shippingAddress } from '@kit.AccountKit';
import { promptAction } from '@kit.ArkUI';
import { CommonUtil, TouristInfo } from 'module_base';

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

  validate(uiContext: UIContext, tourist: TouristInfo) {
    if (!CommonUtil.verifyPhoneNo(tourist.phone)) {
      uiContext.getPromptAction().showToast({ message: '请正确填写游客手机号码', duration: 1000 });
      return false;
    } else if (!CommonUtil.verifyCardNo(tourist.cardNo)) {
      uiContext.getPromptAction().showToast({ message: '请正确填写游客身份证号', duration: 1000 });
      return false;
    } else if (!tourist.name.length || !tourist.phone.length || !tourist.cardNo.length) {
      uiContext.getPromptAction().showToast({ message: '请正确填写游客信息', duration: 1000 });
      return false;
    }
    return true;
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