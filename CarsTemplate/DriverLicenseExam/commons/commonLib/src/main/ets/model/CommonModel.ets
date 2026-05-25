import { AccountUtil, UserInfoModel } from '../utils/AccountUtil'
import { DialogMap } from '../constants/CommonEnums'
import { PermissionUtil } from '../utils/PermissionUtil'
import { RouterModule } from '../utils/RouterModule'

import { Permissions } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import { Logger } from '../utils/Logger';

const TAG: string = 'CommonModel';

@ObservedV2
export class CommonModel {
  private static _instance: CommonModel;
  @Trace allowGetPosition: boolean = false;

  @Trace navStack: NavPathStack = RouterModule.getStack();

  @Trace curIndex: number = 0;

  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();

  public static get instance() {
    if (!CommonModel._instance) {
      CommonModel._instance = new CommonModel();
    }
    return CommonModel._instance;
  }

  // 获取位置授权
  public async requestLocationPermission():Promise<boolean | undefined> {
    const permissions: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION','ohos.permission.LOCATION','ohos.permission.APP_TRACKING_CONSENT'];
    return PermissionUtil.requestPermissions(permissions);
  }

  // 获取地理为位置名称
  public async getLocationName():Promise<string> {
    const permissions: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION','ohos.permission.LOCATION'];
    let addressParam:string = '';
    const allowGetPosition = await PermissionUtil.requestPermissions(permissions);
    this.allowGetPosition = allowGetPosition;
    if (allowGetPosition) {
      try {
        const location = await geoLocationManager.getCurrentLocation();
        if (location) {

            let reverseGeocodeRequest:geoLocationManager.ReverseGeoCodeRequest = {'latitude': location.latitude, 'longitude':  location.longitude, 'maxItems': 1}
            const res = await geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest);
            Logger.info(TAG, '[location]', JSON.stringify(res))
            if (res && res.length > 0) {
              addressParam = res[0].locality || '';
            }
        }
      } catch (e) {
        Logger.error(TAG, JSON.stringify(e));
      }
    }

    return addressParam;
  }

  // 绑定手机号
  public requestPhoneNumber() {
    RouterModule.openDialog(DialogMap.BIND_PHONE_DIALOG,);
  }
}
