import { UtilLog } from '@hw-agconnect/util-log';
import { abilityAccessCtrl, PermissionRequestResult } from '@kit.AbilityKit';
import { display } from '@kit.ArkUI';
import { geoLocationManager } from '@kit.LocationKit';
import { map, mapCommon, site } from '@kit.MapKit';
import { AccommodationInfo, AttractionInfo, AttractionUtil, CateringInfo, Constant, https } from 'module_base';
import {
  GUIDE_TABS_INFO,
  HEIGHT_LOW_MIDDLE,
  HEIGHT_LOW_SMALL,
  LOCATION_PERMISSION,
  USER_GRANT_SUCCESS,
} from '../constants/Constant';
import { mapAccommodationInfo, mapCateringInfo } from '../mapper/Index';
import { BreakpointStatus } from '../model/BreakpointModel';
import { Guide, LocationType } from '../model/GuideInfo';

const TAG = '[AttractionGuideVM]';

@ObservedV2
export class AttractionGuideVM {
  // 默认展示景点列表
  @Trace guideInfo: Guide<AttractionInfo | CateringInfo | AccommodationInfo> = GUIDE_TABS_INFO[0];
  @Trace type: number = 0;
  @Trace selectedGuide: ESObject = AttractionUtil.getAttraction().attractions[0];
  @Trace attractionInfo: AttractionInfo[] = [];
  @Trace isShow: boolean = true;
  @Trace columnHeight: number = 120;
  @Trace tempColumnHeight: number = 120;
  @Trace currentBreakpoint: string = 'sm';
  @Trace windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Trace myLocation: geoLocationManager.Location = {
    latitude: 0,
    longitude: 0,
    altitude: 0,
    accuracy: 0,
    speed: 0,
    timeStamp: 0,
    direction: 0,
    timeSinceBoot: 0,
  };
  mapController: map.MapComponentController = new map.MapComponentController();
  pointIds: Map<string, AttractionInfo | CateringInfo | AccommodationInfo> = new Map();
  panOptionHeight: PanGestureOptions = new PanGestureOptions({
    direction: PanDirection.Up | PanDirection.Down,
  });
  panOptionPosition: PanGestureOptions = new PanGestureOptions({
    direction: PanDirection.Left | PanDirection.Right, distance: 10,
  });
  public static _instance: AttractionGuideVM;

  public static get instance() {
    if (!AttractionGuideVM._instance) {
      AttractionGuideVM._instance = new AttractionGuideVM();
    }
    return AttractionGuideVM._instance;
  }

  @Computed
  get sheetMarginBottom(){
    if (this.currentBreakpoint === BreakpointStatus.SM) {
      return Constant.BOTTOM_TAB_BAR_HEIGHT + this.windowBottomHeight
    }else if (this.currentBreakpoint === BreakpointStatus.MD) {
      return Constant.BOTTOM_TAB_BAR_HEIGHT + this.windowBottomHeight + 12
    }else{
      return this.windowBottomHeight + 8
    }
  }

  changeGuideInfo(type: number) {
    if (type === 1) {
      this.guideInfo.data = AppStorage.get('cateringList')!;
    } else if (type === 2) {
      this.guideInfo.data = AppStorage.get('accommodationList')!;
    } else if (type === 3) {
      this.guideInfo.data = AppStorage.get('toiletList')!;
    } else if (type === 0) {
      this.guideInfo.data = this.attractionInfo;
    }
  }

  initGuideInfo() {
    this.guideInfo.data = this.attractionInfo;

    if (!AppStorage.get('accommodationList')) {
      this.getPoiListByType(1, 'ACCOMMODATION').then((res) => {
        let accommodationSites = mapAccommodationInfo(res.sites ?? []);
        AppStorage.setOrCreate('accommodationList', accommodationSites)!;
      });
    }
    if (!AppStorage.get('cateringList')) {
      this.getPoiListByType(1, 'EATING_DRINKING').then((res) => {
        let cateringSites = mapCateringInfo(res.sites ?? []);
        AppStorage.setOrCreate('cateringList', cateringSites)!;
      });
    }
  }

  setCurrentBreakpoint(point: string) {
    this.currentBreakpoint = point
  }

  // 监听屏幕大小变化
  setScreenListen(onChange: (maxHeight: number) => void) {
    try {
      display.on('change', () => {
        const defaultDisplay = display.getDefaultDisplaySync();
        onChange(defaultDisplay.height);
      });
    } catch (e) {
      UtilLog.error(TAG, 'display.on failed', 'error: ' + JSON.stringify(e));
    }
  }

   getSheetMinHeight() {
    return this.currentBreakpoint === BreakpointStatus.XS ? HEIGHT_LOW_SMALL : HEIGHT_LOW_MIDDLE;
  }

  getPoiListByType(pageIndex: number, poiType: string, range?: number) {
    let params: site.NearbySearchParams = {
      // 指定关键字
      query: '', // 经纬度坐标
      location: {
        // todo 模拟景区附近地点，实际开发以用户定位为准
        latitude: this.guideInfo.data[0].latitude, longitude: this.guideInfo.data[0].longitude,
      }, // 指定地理位置的范围半径
      radius: 1000, // 指定需要展示的poi类别
      poiTypes: [poiType],
      language: 'zh_CN',
      pageSize: 20,
      pageIndex: pageIndex,
    }; // 返回周边搜索结果
    let result: Promise<site.NearbySearchResult> = new Promise((resolve, reject) => {
      reject(new Error('nearbySearch error'));
    });

    try {
      result = site.nearbySearch(params);
    } catch (e) {
      UtilLog.error(0x0000, 'AttractionGuideVM', `nearbySearch = ${JSON.stringify(e)}`);
    }

    return result;
  }

  getPoiListByText(poiText: string, range?: number) {
    let params: site.SearchByTextParams = {
      query: poiText,
      location: {
        latitude: this.myLocation.latitude, longitude: this.myLocation.longitude,
      },
      radius: range,
      language: 'zh_CN',
    };

    let result: Promise<site.SearchByTextResult> = new Promise((resolve, reject) => {
      reject(new Error('nearbySearch error'));
    });

    try {
      result = site.searchByText(params);
    } catch (e) {
      UtilLog.error(0x0000, 'AttractionGuideVM', `nearbySearch = ${JSON.stringify(e)}`);
    }

    return result;
  }

  checkPermissionGrant(context: Context): Promise<boolean> {
    return new Promise((resolve, reject) => {
      let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      atManager.requestPermissionsFromUser(context, LOCATION_PERMISSION).then((data) => {
        let grantStatus: Array<number> = data.authResults;
        let hasMapPermission = grantStatus.every(item => item === USER_GRANT_SUCCESS);
        resolve(hasMapPermission);
      }).catch((err: BusinessError) => {
        reject(err.message);
        UtilLog.error(TAG, `Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
      });
    });
  }

  /**
   * 申请用户权限
   * @param context
   * @param permissions
   * @returns
   */
  async requestPermissions(context: Context): Promise<boolean> { // 向用户申请
    const atManager = abilityAccessCtrl.createAtManager();
    return atManager.requestPermissionsFromUser(context, LOCATION_PERMISSION)
      .then(async (result: PermissionRequestResult) => {
        if (result.authResults.every(v => v === 0)) {
          UtilLog.info(TAG, 'permissions granted: ' + JSON.stringify(LOCATION_PERMISSION));
          return true;
        } // 二次向用户申请
        if ((result.dialogShownResults ?? []).some(v => !v)) {
          UtilLog.info(TAG, 'start reapply permissions: ' + JSON.stringify(LOCATION_PERMISSION));
          try {
            const resp = await atManager.requestPermissionOnSetting(context, LOCATION_PERMISSION);
            return resp.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
          } catch (error) {
            UtilLog.error(TAG, 'requestPermissionOnSetting fail, error: ' + JSON.stringify(error));
            return false;
          }
        }
        return false;
      })
      .catch((error: BusinessError) => {
        UtilLog.error(TAG, 'requestPermissionsFromUser fail, error: ' + JSON.stringify(error));
        return false;
      });
  }

  async getLocation(ctx: Context) {
    let permission: boolean = await this.checkPermissionGrant(ctx);
    if (!permission) {
      // 请求权限，等待权限授予结果
      const granted = await this.requestPermissions(ctx);
      if (granted) { // 权限授予成功，获取用户位置
        this.getCurrentLocation();
      } else {
        UtilLog.warn(TAG, 'Location permission denied, cannot get user location');
      }
    } else { // 已有权限，直接获取位置
      this.getCurrentLocation();
      ;
    }
  }

  getCurrentLocation(): Promise<geoLocationManager.Location> {
    return geoLocationManager.getCurrentLocation()
      .then((location: geoLocationManager.Location) => {
        this.mapController?.setMyLocation(location);
        this.mapController?.setMyLocationEnabled(true);
        this.mapController?.setMyLocationControlsEnabled(true);
        this.myLocation = location;
        return location;
      })
      .catch((error: Error) => {
        UtilLog.error(TAG, 'getCurrentLocation failed', 'getCurrentLocation error: ' + JSON.stringify(error));
        throw error;
      });
  }

  moveToMyLocation(uiContext: UIContext) {
    if (this.myLocation) {
      const wgs84Position: mapCommon.LatLng = {
        latitude: this.myLocation.latitude,
        longitude: this.myLocation.longitude,
      };
      const gcj02Position: mapCommon.LatLng =
        map.convertCoordinateSync(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);
      this.mapController?.animateCamera(map.newLatLng({
        latitude: gcj02Position.latitude, longitude: gcj02Position.longitude,
      }, 15), 200);
    } else {
      uiContext.getPromptAction().showToast({ message: '获取当前位置失败，请检查定位权限' });
    }
  }

  createMakerListener(mainPathStack: NavPathStack) {
    let mapEventManager: map.MapEventManager = this.mapController?.getEventManager();
    mapEventManager.on('markerClick', (marker: map.Marker) => {
      if (this.type === LocationType.ATTRACTION) {
        let maker = this.pointIds.get(marker.getId()) as AttractionInfo;
        mainPathStack.pushPathByName('AttractionDetail', maker.attractionId);
      } else if (this.type === LocationType.CATERING) {
        let maker = this.pointIds.get(marker.getId()) as CateringInfo;
        this.goCateringDetail(maker, mainPathStack);
      } else if (this.type === LocationType.ACCOMMODATION) {
        let maker = this.pointIds.get(marker.getId()) as AccommodationInfo;
        this.goAccommodationDetail(maker, mainPathStack);
      }
    });
  }

  goCateringDetail(maker: CateringInfo, mainPathStack: NavPathStack) {
    https.getCateringDetail(maker.siteId).then((res) => {
      maker.banners = res.data.banner;
      maker.startPrice = res.data.startPrice;
      maker.detailImages = res.data.images;
      maker.detail = res.data.detail;
      maker.openHours = res.data.openHour;
      mainPathStack.pushPathByName('CateringDetail', maker);
    });
  }

  goAccommodationDetail(maker: AccommodationInfo, mainPathStack: NavPathStack) {
    https.getAccommodationDetail(maker.siteId).then((res) => {
      maker.banners = res.data.banner;
      maker.detailImages = res.data.images;
      maker.detail = res.data.detail;
      maker.labels = res.data.label;
      mainPathStack.pushPathByName('AccommodationDetail', maker);
    });
  }
}
