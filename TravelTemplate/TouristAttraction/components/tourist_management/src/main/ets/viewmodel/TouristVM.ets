import { shippingAddress } from '@kit.AccountKit';
import { CommonUtil, TouristInfo } from 'module_base';
import { BreakpointNameEnum } from '../constant/GridRowColSetting';

@ObservedV2
export class TouristVM {
  @Trace touristList: TouristInfo[] = [];
  @Trace currentBreakpoint: string = 'sm';
  public static _instance: TouristVM;

  public static get instance() {
    if (!TouristVM._instance) {
      TouristVM._instance = new TouristVM();
    }
    return TouristVM._instance;
  }

  @Computed
  get getTouristLanes() {
    return ['sm', 'md'].includes(this.currentBreakpoint) ? 1 : 2;
  }

  @Computed
  get getAddWidth() {
    return ['sm', 'md'].includes(this.currentBreakpoint) ? '100%' : 400;
  }

  getSheetHeight(isInReserve: boolean) {
    if (isInReserve) {
      return this.currentBreakpoint === BreakpointNameEnum.SM ? 748 : 612;
    } else {
      return this.currentBreakpoint === BreakpointNameEnum.SM ? 748 : 560;
    }
  }

  setBreakpoint(breakpoint: string) {
    this.currentBreakpoint = breakpoint;
  }

  validate(uiContext: UIContext, tourist: TouristInfo) {
    if (!tourist.name.length) {
      uiContext.getPromptAction().showToast({ message: '请正确填写游客姓名', duration: 1000 });
      return false;
    } else if (!tourist.phone.length || !CommonUtil.verifyPhoneNo(tourist.phone)) {
      uiContext.getPromptAction().showToast({ message: '请正确填写游客手机号码', duration: 1000 });
      return false;
    } else if (tourist.cardType < 0) {
      uiContext.getPromptAction().showToast({ message: '请选择证件类型', duration: 1000 });
      return false;
    } else if (!tourist.cardNo.length || !CommonUtil.verifyCardNo(tourist.cardNo)) {
      uiContext.getPromptAction().showToast({ message: '请正确填写证件号码', duration: 1000 });
      return false;
    }
    return true;
  }

  getCheckedTourists() {
    let checkedItems = this.touristList.filter((item) => item.isChecked);
    return checkedItems;
  }

  mapDistrict(systemAddress: shippingAddress.AddressInfo): string {
    const directCities = ['北京', '天津', '上海', '重庆'];
    const isDirectCity = directCities.some(c => systemAddress.provinceName.includes(c));
    return systemAddress.provinceName + (isDirectCity ? '' : `省`) + systemAddress.cityName +
      systemAddress.districtName + systemAddress.streetName;
  }
}