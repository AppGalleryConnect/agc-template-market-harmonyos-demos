import { AppStorageV2 } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { common } from '@kit.AbilityKit';
import { shippingAddress } from '@kit.AccountKit';
import { geoLocationManager } from '@kit.LocationKit';
import { mapCommon, sceneMap, site } from '@kit.MapKit';
import {
  BreakpointModel,
  BreakpointNameEnum,
  CommonUtil,
  LazyDataSource,
  Logger,
  PermissionUtils,
  SystemUtil,
} from 'common';
import { AddressRequest, https } from 'network';
import { AddressInfo, TouristInfo } from 'types';
import { mapAddressInfo } from '../mapper/Index';

const TAG = '[AddressVM]';

@ObservedV2
export class AddressVM {
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace addressList: AddressInfo[] = [];
  @Trace touristList: LazyDataSource<TouristInfo> = new LazyDataSource();
  @Trace showAddressSheet: boolean = false;
  @Trace isEdit: boolean = false;
  @Trace cloneAddressInfo: AddressInfo = new AddressInfo();
  @Trace addressInfo: AddressInfo = new AddressInfo();
  @Trace myLocation?: geoLocationManager.Location;
  @Trace isChoosingLocation: boolean = false;
  @Trace isSelectingDistrict: boolean = false;
  @Trace isSelectingAddress: boolean = false;
  @Trace isSaving: boolean = false;
  @Trace nameError: boolean = false;
  @Trace phoneError: boolean = false;
  @Trace districtError: boolean = false;
  @Trace detailError: boolean = false;
  public static _instance: AddressVM;

  public static get instance() {
    if (!AddressVM._instance) {
      AddressVM._instance = new AddressVM();
    }
    return AddressVM._instance;
  }

  getFunctionLane() {
    return [BreakpointNameEnum.MD, BreakpointNameEnum.SM].includes(this.breakPointModel.currentBreakpoint) ? 1 : 2;
  }

  @Computed
  private get isProcessing(): boolean {
    return this.isChoosingLocation || this.isSelectingDistrict || this.isSelectingAddress || this.isSaving;
  }

  validate(address: AddressInfo) {
    this.nameError = !address.name.length;
    this.phoneError = !address.phone.length || !CommonUtil.verifyPhoneNo(address.phone);
    this.districtError = !address.district.length;
    this.detailError = !address.detail.length;
    return this.nameError || this.phoneError || this.districtError || this.detailError;
  }

  editItemInfo(item: AddressInfo, isEdit: boolean) {
    let params: AddressRequest = {
      id: isEdit ? item.id : SystemUtil.doRandBySync(2),
      name: item.name,
      phone: item.phone,
      district: item.district,
      detail: item.detail,
      type: item.type,
      latitude: item.latitude,
      longitude: item.longitude,
    };

    if (isEdit) {
      https.modifyAddress(params).then((res) => {
        if (res.code === 0) {
          Logger.info('modify tourist success');
          this.getAddressList();
        }
      });
    } else {
      https.createAddress(params).then((res) => {
        if (res.code === 0) {
          Logger.info('create tourist success');
          this.getAddressList();
        }
      });
    }
  }

  getAddressList() {
    https.getAddressList().then((res) => {
      this.addressList = mapAddressInfo(res.data);
      Logger.info('getAddress list success ' + this.addressList.length);
    });
  }

  deleteItemInfo(id: string) {
    https.deleteAddress(id).then((res) => {
      if (res.code === 0) {
        this.addressList = this.addressList.filter(item => item.id !== id);
        Logger.info('delete address success');
      }
    });
  }

  mapDistrict(systemAddress: shippingAddress.AddressInfo): string {
    const directCities = ['北京', '天津', '上海', '重庆'];
    const isDirectCity = directCities.some(c => systemAddress.provinceName.includes(c));
    return systemAddress.provinceName + (isDirectCity ? '' : `省`) + systemAddress.cityName +
      systemAddress.districtName + systemAddress.streetName;
  }


  async importSystemAddress(uiContext: UIContext) {
    let systemAddress: shippingAddress.AddressInfo = await SystemUtil.getSystemAddress(uiContext.getHostContext()!);
    if (systemAddress.userName) { // 映射收货地址
      this.addressInfo.detail = systemAddress.detailedAddress;
      this.addressInfo.phone = systemAddress.mobileNumber;
      this.addressInfo.name = systemAddress.userName;
      this.addressInfo.district = this.mapDistrict(systemAddress);
    }
  }

  async selectLocation(uiContext: UIContext) {

    this.myLocation = await PermissionUtils.getLocation(uiContext);
    if (this.myLocation) {
      const isNeedSite =
        !this.cloneAddressInfo.latitude || !this.cloneAddressInfo.longitude && this.cloneAddressInfo.district;
      if (isNeedSite) { // 根据地址获取经纬度
        const address = this.cloneAddressInfo.district + (this.cloneAddressInfo.detail ?? '');
        let params: site.GeocodeParams = {
          query: address, // 目标地址
          language: 'zh', // 返回结果语言（中文）
        };
        try {
          const result = await site.geocode(uiContext.getHostContext(), params);
          const siteInfo = result?.sites?.[0];
          if (siteInfo?.location) {
            this.cloneAddressInfo.latitude = siteInfo.location.latitude;
            this.cloneAddressInfo.longitude = siteInfo.location.longitude;
          }
        } catch (error) {
          UtilLog.error(TAG, `geocode failed, error: ${JSON.stringify(error)}`);
        }
      }

      const wgs84Position: mapCommon.LatLng = {
        latitude: this.cloneAddressInfo.latitude || this.myLocation?.latitude,
        longitude: this.cloneAddressInfo.longitude || this.myLocation?.longitude,
      };
      let locationChoosingOptions: sceneMap.LocationChoosingOptions = {
        location: {
          latitude: wgs84Position.latitude, longitude: wgs84Position.longitude,
        },
        language: 'zh',
        searchEnabled: true,
        showNearbyPoi: true,
      };
      const context = uiContext.getHostContext() as common.UIAbilityContext;
      sceneMap.chooseLocation(context, locationChoosingOptions).then((data) => {
        const addressInfo = data.addressComponent;
        let tempAddress = data.address;
        if (addressInfo) {
          tempAddress =
            `${addressInfo.adminLevel1 ?? ''}${addressInfo.adminLevel2 ?? ''}${addressInfo.adminLevel3 ?? ''}`;
        }
        this.cloneAddressInfo.district = tempAddress || '';
        this.cloneAddressInfo.detail = data.name || '';
        this.cloneAddressInfo.latitude = data.location.latitude;
        this.cloneAddressInfo.longitude = data.location.longitude;
        UtilLog.info(TAG, 'ChooseLocation', 'Succeeded in choosing location.');
      }).catch((err: BusinessError) => {
        UtilLog.error(TAG, 'ChooseLocation', `Failed to choose Location, code: ${err.code}, message: ${err.message}`);
      });
    }
  }

  handleSelectDistrict(uiContext: UIContext): void {
    if (this.isProcessing) {
      return;
    }
    uiContext.getFocusController().clearFocus();
    this.isSelectingDistrict = true; // 当前 selectDistrict 在某些特殊情况下不会产生任何回调，因此 1 秒后无条件还原状态变量
    const timeoutId: number = setTimeout(() => this.isSelectingDistrict = false, 1000);
    const options: sceneMap.DistrictSelectOptions = {
      countryCode: 'CN', language: 'zh', cancelCallback: () => {
        clearTimeout(timeoutId);
        this.isSelectingDistrict = false;
      },
    };
    sceneMap.selectDistrict(uiContext.getHostContext(), options).then((result: sceneMap.DistrictSelectResult) => {
      this.cloneAddressInfo.district = '';
      let lastAdded = '';
      for (let i = 1; i < result.districts.length; i++) {
        const name = result.districts[i].name ?? '';
        if (name && name !== lastAdded) {
          this.cloneAddressInfo.district += name;
          lastAdded = name;
        }
      }
    }).catch((e: BusinessError<void>) => this.showErrorToast(uiContext, e)).finally(() => {
      clearTimeout(timeoutId);
      this.isSelectingDistrict = false;
    });
  }

  private showErrorToast(uiContext: UIContext, error: ESObject): void {
    let message: string = '';
    if (error.message) {
      if (!error.code && error.code !== 0) {
        message = `error: ${error.message}`;
      } else {
        message = `code: ${error.code}, msg: ${error.message}`;
      }
    } else if (typeof error === 'string') {
      message = `error: ${error}`;
    }
    uiContext.getPromptAction().showToast({
      message: message ? message : `error: ${JSON.stringify(error)}`,
      backgroundBlurStyle: BlurStyle.NONE,
      backgroundColor: '#FFFF9800',
      textColor: $r('sys.color.font_primary'),
    });
  }
}