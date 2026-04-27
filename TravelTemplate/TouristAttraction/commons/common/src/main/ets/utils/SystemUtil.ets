import { abilityAccessCtrl, bundleManager, common, Permissions, Want } from '@kit.AbilityKit';
import { sceneMap, site } from '@kit.MapKit';
import { shippingAddress } from '@kit.AccountKit';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { LocationUtil } from './AppStorageV2Util/LocationUtil';
import { call } from '@kit.TelephonyKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { calendarManager } from '@kit.CalendarKit';
import { serviceNotification } from '@kit.PushKit';
import { PermissionRequestResult } from '@ohos.abilityAccessCtrl';

export class SystemUtil {
  static getPoiListByType(pageIndex: number, poiType: string, range?: number) {
    let params: site.NearbySearchParams = {
      // 指定关键字
      query: '',
      // 经纬度坐标
      location: {
        latitude: LocationUtil.getLocationInfo().latitude,
        longitude: LocationUtil.getLocationInfo().longitude,
      },
      // 指定地理位置的范围半径
      radius: 1000,
      // 指定需要展示的poi类别
      poiTypes: [poiType],
      language: 'zh_CN',
      pageSize: 20,
      pageIndex: pageIndex,
    };
    // 返回周边搜索结果
    let result: Promise<site.NearbySearchResult> = new Promise((resolve, reject) => {
      reject(new Error('nearbySearch error'))
    })

    try {
      result = site.nearbySearch(params);
    } catch (e) {
      Logger.error(0x0000, 'AttractionGuideVM', `nearbySearch = ${JSON.stringify(e)}`);
    }

    return result
  }

  static getPoiListByText(poiText: string, range?: number) {
    let params: site.SearchByTextParams = {
      query: poiText,
      location: {
        latitude: LocationUtil.getLocationInfo().latitude,
        longitude: LocationUtil.getLocationInfo().longitude,
      },
      radius: range,
      language: 'zh_CN',
    };
    let result: Promise<site.SearchByTextResult> = new Promise((resolve, reject) => {
      reject(new Error('nearbySearch error'))
    })

    try {
      result = site.searchByText(params);
    } catch (e) {
      Logger.error(0x0000, 'AttractionGuideVM', `nearbySearch = ${JSON.stringify(e)}`);
    }

    return result
  }

  static routerToPetalMap(latitude: number, longitude: number, name: string, context: common.UIAbilityContext) {
    let petalMapWant: Want = {
      bundleName: 'com.huawei.hmos.maps.app',
      uri: 'maps://routes',
      parameters: {
        linkSource: 'com.atomicservice.5765880207855657821',
        destinationLatitude: latitude,
        destinationLongitude: longitude,
        destinationName: name,
      },
    }
    context.startAbility(petalMapWant);
  }

  static getSystemAddress(context: Context) {
    return new Promise<shippingAddress.AddressInfo>((resolve, reject) => {
      try {
        shippingAddress.chooseAddress(context).then((data: shippingAddress.AddressInfo) => {
          Logger.info('testTag', 'Succeeded in choosing address.');
          resolve(data)
        }).catch((error: BusinessError) => {
          reject(error)
        })
      } catch (error) {
        reject(error)
      }
    })
  }

  static getCascadeInfo(context: common.UIAbilityContext) {
    let district: string = '';
    let districtSelectOptions: sceneMap.DistrictSelectOptions = {
      countryCode: 'CN',
    };

    return new Promise<string>((resolve, reject) => {
      sceneMap.selectDistrict(context, districtSelectOptions).then((data) => {
        Logger.info('SelectDistrict', 'Succeeded in selecting district.');
        for (let i = 1; i < data.districts.length; i++) {
          district += data.districts[i].name;
        }
        resolve(district);
      }).catch((err: BusinessError) => {
        Logger.error('SelectDistrict', `Failed to select district, code: ${err.code}, message: ${err.message}`);
        reject('');
      });
    });
  }

  static triggerForCall(uiContext: UIContext, phoneNo: string) {
    try {
      call.makeCall(phoneNo, (err) => {
        if (err) {
          Logger.error('make call success');
          uiContext.getPromptAction().showToast({ message: '拨打号码失败' });
        } else {
          Logger.info('make call success');
        }
      });
    } catch (error) {
      Logger.error('SelectDistrict', `Failed to makeCall, ${JSON.stringify(error)}}`);
    }
  }

  static doRandBySync(len: number): string {
    let data: string = '';
    let rand = cryptoFramework.createRandom();
    try {
      let randData = rand.generateRandomSync(len);
      if (randData != null) {
        for (let i = 0; i < randData.data.length; i++) {
          data += randData.data[i];
        }
      } else {
        Logger.error('[Sync]: get rand result fail!');
      }
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      Logger.error(`do rand failed, ${e.code}, ${e.message}`);
    }
    return data;
  }

  static copyText(uiContext: UIContext, orderNo: string) {
    try {
      const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, orderNo);
      const systemPasteboard = pasteboard.getSystemPasteboard();
      systemPasteboard.setData(pasteboardData);
      systemPasteboard.getData().then((data) => {
        if (data) {
          uiContext.getPromptAction().showToast({ message: '复制成功' });
        } else {
          uiContext.getPromptAction().showToast({ message: '复制失败' });
        }
      });
    } catch (error) {
      uiContext.getPromptAction().showToast({ message: '复制失败' });
      let e: BusinessError = error as BusinessError;
      Logger.error(`do rand failed, ${e.code}, ${e.message}`);
    }
  }

  /**
   * 检查用户是否授权
   * @param permission
   * @returns
   */
  public static async checkPermissionGrant(permission: Permissions): Promise<boolean> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    // 获取应用程序的accessTokenID
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      tokenId = bundleInfo.appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`)
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`)
    }

    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }

  /**
   * 根据上下文获取日程管理器对象calendarMgr，用于对日历账户进行相关管理操作
   * @returns
   */
  public static async getCalendarMgr(context: Context) {
    const permissions: Permissions[] = [
      'ohos.permission.READ_CALENDAR',
      'ohos.permission.WRITE_CALENDAR',
    ];

    const isGrantedRead = await SystemUtil.checkPermissionGrant(permissions[0]);
    const isGrantedWrite = await SystemUtil.checkPermissionGrant(permissions[1]);

    if (isGrantedRead && isGrantedWrite) {
      Logger.info('already granted calendar permission')
      return calendarManager.getCalendarManager(context);
    }

    const atManager = abilityAccessCtrl.createAtManager();


    return atManager.requestPermissionsFromUser(context, permissions).then(async (result: PermissionRequestResult) => {
      Logger.info(`get Permission success, result: ${JSON.stringify(result)}`)
      if (result.authResults.every(v => v === 0)) {
        return calendarManager.getCalendarManager(context);
      }
      // 首次拒绝后，二次弹窗申请
      if (result.dialogShownResults?.some(v => !v)) {
        const arr: Array<abilityAccessCtrl.GrantStatus> =
          await atManager.requestPermissionOnSetting(context, permissions);
        if (arr.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)) {
          return calendarManager.getCalendarManager(context);
        }
        return null;
      }

      return null;
    })
  }

  // 添加日程
  static async addEvent(time: number, name: string, context: Context): Promise<boolean> {
    const calendarMgr: calendarManager.CalendarManager | null = await SystemUtil.getCalendarMgr(context);
    if (!calendarMgr) {
      return false;
    }
    const date = new Date(time);
    const event: calendarManager.Event = {
      title: `预约的${name}`, // 日程标题
      type: calendarManager.EventType.NORMAL,
      startTime: date.getTime(),
      endTime: date.getTime() + 60 * 60 * 1000,
      reminderTime: [30], // 距开始时间提前10分钟提醒
    };

    const calendar = await calendarMgr.getCalendar();
    const res = await calendar.addEvent(event)
    return res < 0 ? false : true
  };

  /**
   * 发起订阅请求
   * @returns
   */
  public static async requestSubscribeNotification(context: Context):
    Promise<serviceNotification.RequestResult | null> {
    try {
      // todo 用户自定义配置模板ID
      const entityIds: string[] = ['1997DEA0FA00BC80']
      const type: serviceNotification.SubscribeNotificationType =
        serviceNotification.SubscribeNotificationType.SUBSCRIBE_WITH_HUAWEI_ID;
      const res = await serviceNotification.requestSubscribeNotification(context, entityIds, type);
      Logger.info('Succeeded in requesting serviceNotification: %{public}s' + JSON.stringify(res));
      return res!;
    } catch (err) {
      Logger.error('Failed to request serviceNotification: ' + JSON.stringify(err as BusinessError));
      return null;
    }
  }
}