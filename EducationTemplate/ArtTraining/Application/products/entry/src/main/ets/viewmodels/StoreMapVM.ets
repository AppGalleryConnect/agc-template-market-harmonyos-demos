import { map, mapCommon } from '@kit.MapKit';
import { Logger, PopViewUtil, StoreInfo } from 'commonlib';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { bundleManager, common, Want } from '@kit.AbilityKit';
import { mapOptionsDialog } from 'componentlib';

const DEFAULT_LATITUDE = 32.120750;
const DEFAULT_LONGITUDE = 118.788765;
const TAG = '[StoreMapVM]';

@ObservedV2
export class StoreMapVM {
  @Trace latitude: number = DEFAULT_LATITUDE;
  @Trace longitude: number = DEFAULT_LONGITUDE;
  @Trace mapOptions: mapCommon.MapOptions = {
    position: {
      target: {
        latitude: DEFAULT_LATITUDE,
        longitude: DEFAULT_LONGITUDE,
      },
      zoom: 15,
    },
  };
  mapController?: map.MapComponentController;
  marker?: map.Marker;
  callback?: AsyncCallback<map.MapComponentController>;
  mapEventManager?: map.MapEventManager;
  private static _instance: StoreMapVM;

  public static get instance() {
    if (!StoreMapVM._instance) {
      StoreMapVM._instance = new StoreMapVM();
    }
    return StoreMapVM._instance;
  }

  public initController(storeInfo: StoreInfo) {
    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapEventManager = this.mapController?.getEventManager();
        await this.getLocationInfo();
        this.setMarker(storeInfo);
      }
    };
  }

  public async getLocationInfo() {
    let target: mapCommon.LatLng = {
      latitude: this.latitude + 0.002,
      longitude: this.longitude + 0.004,
    };
    let cameraPosition: mapCommon.CameraPosition = {
      target: target,
      zoom: 15,
    };
    // 新建CameraUpdate对象
    let cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    // 在1000ms内以动画的形式移动相机
    this.mapController?.animateCamera?.(cameraUpdate, 1000);
  }

  public async setMarker(storeInfo: StoreInfo) {
    let markerOptions: mapCommon.MarkerOptions = {
      position: {
        latitude: this.latitude,
        longitude: this.longitude,
      },
      visible: true,
      clickable: true,
      icon: 'ic_position.svg',
      zIndex: 99,
      infoWindowAnchorU:1,

      title: storeInfo.shopName,
      snippet: storeInfo.address,
    };
    // 创建Marker
    this.marker = await this.mapController?.addMarker(markerOptions);
    this.marker?.setInfoWindowVisible(true);
  }

  public handleClickGuide() {
    PopViewUtil.openDialog(
      wrapBuilder(mapOptionsDialog),
      { alignment: DialogAlignment.Bottom },
    );
  }

  public async jumpToMapApp() {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION;
    try {
      const bundleInfo = await bundleManager.getBundleInfoForSelf(bundleFlags);
      if (bundleInfo.name && this.mapOptions) {
        let petalMapWant: Want = {
          bundleName: 'com.huawei.hmos.maps.app',
          uri: 'maps://routes',
          parameters: {
            linkSource: bundleInfo.name,
            destinationLatitude: this.latitude,
            destinationLongitude: this.longitude,
          },
        };
        let context = getContext(this) as common.UIAbilityContext;
        context.startAbility(petalMapWant);
      }
    } catch (err) {
      Logger.error(TAG, 'jump to map app failed. Cause: %{public}s', err.message);
    }
  }
}
