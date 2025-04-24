import { AccountUtil, UserInfoModel } from '../utils/AccountUtil'
import { DialogMap } from '../constants/CommonEnums'
import { PermissionUtil } from '../utils/PermissionUtil'
import { RouterModule } from '../utils/RouterModule'

import { Permissions } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import { map, mapCommon, site } from '@kit.MapKit';

const TAG: string = 'CommonModel';

@ObservedV2
export class CommonModel {
  private static _instance: CommonModel;
  @Trace allowGetPosition: boolean = false;

  @Trace navStack: NavPathStack = RouterModule.getStack();

  @Trace curIndex: number = 0;

  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();

  @Trace selectShopId: string = '';

  @Trace secondTabIndex: number = 0;

  public static get instance() {
    if (!CommonModel._instance) {
      CommonModel._instance = new CommonModel();
    }
    return CommonModel._instance;
  }

  // 初始化
  public async init() {
    AccountUtil.silentLogin();
  }

  // 获取位置授权
  public async requestLocationPermission():Promise<boolean | undefined> {
    const permissions: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION','ohos.permission.LOCATION'];
    return PermissionUtil.requestPermissions(permissions);
  }

  // 获取地理为位置名称
  public async getLocationName():Promise<string> {
    const permissions: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION','ohos.permission.LOCATION'];
    let addressParam:string = '';
    const allowGetPosition = await PermissionUtil.requestPermissions(permissions);
    this.allowGetPosition = allowGetPosition;
    if (allowGetPosition) {
      const location = await geoLocationManager.getCurrentLocation();
      if (location) {
        try {
          let reverseGeocodeRequest:geoLocationManager.ReverseGeoCodeRequest = {'latitude': location.latitude, 'longitude':  location.longitude, 'maxItems': 1}
          const res = await geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest);
          console.log('[location]',JSON.stringify(res))
          if (res && res.length > 0) {
            addressParam = res[0].locality || '';
          }
        } catch (e) {
          console.log(e);
        }
      }
    }

    return addressParam;
  }

  // 绑定手机号
  public requestPhoneNumber() {
    RouterModule.openDialog(DialogMap.BIND_PHONE_DIALOG,);
  }
}
