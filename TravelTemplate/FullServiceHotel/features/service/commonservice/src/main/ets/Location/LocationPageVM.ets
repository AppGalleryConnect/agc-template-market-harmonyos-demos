import { map, mapCommon } from '@kit.MapKit';
import { https } from 'network';
import { Logger, PopViewUtils } from 'commonlib';
import { HotelCoordinate } from './types';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { bundleManager, common, Want } from '@kit.AbilityKit';

const DEFAULT_LATITUDE = 31.97;
const DEFAULT_LONGITUDE = 118.75;
const TAG = '[LocationPageVM]';

@ObservedV2
export class LocationPageVM {
  @Trace title: string = '';
  @Trace hotelCoordinate: HotelCoordinate = {
    latitude: DEFAULT_LATITUDE,
    longitude: DEFAULT_LONGITUDE,
  };
  @Trace mapOptions: mapCommon.MapOptions = {
    position: {
      target: {
        latitude: DEFAULT_LATITUDE,
        longitude: DEFAULT_LONGITUDE,
      },
      zoom: 10,
    },
  };
  @Trace mapController?: map.MapComponentController;
  marker?: map.Marker;
  callback?: AsyncCallback<map.MapComponentController>;
  mapEventManager?: map.MapEventManager;
  private static _instance: LocationPageVM;

  public static get instance() {
    if (!LocationPageVM._instance) {
      LocationPageVM._instance = new LocationPageVM();
    }
    return LocationPageVM._instance;
  }

  public initController() {
    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapEventManager = this.mapController?.getEventManager();
        await this.getLocationInfo();
        this.setMarker();
      }
    };
  }

  public async getLocationInfo() {
    if (!this.title) {
      const res = await https.getTrafficDetail();
      if (res.code !== 0) {
        Logger.error('get traffic info failed');
      }
      let trafficResp = res.data;
      this.title = trafficResp.name;
      const coordinate: string[] = trafficResp.coordinate.split(',');
      this.hotelCoordinate.longitude = Number(coordinate[0]);
      this.hotelCoordinate.latitude = Number(coordinate[1]);
    }
    let target: mapCommon.LatLng = {
      latitude: this.hotelCoordinate.latitude,
      longitude: this.hotelCoordinate.longitude,
    };
    let cameraPosition: mapCommon.CameraPosition = {
      target: target,
      zoom: 15,
    };
    // 新建CameraUpdate对象
    let cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    // 在1000ms内以动画的形式移动相机
    this.mapController?.animateCamera?.(cameraUpdate, 1500);
  }

  public async setMarker() {
    let markerOptions: mapCommon.MarkerOptions = {
      position: {
        latitude: this.hotelCoordinate.latitude,
        longitude: this.hotelCoordinate.longitude,
      },
      visible: true,
      zIndex: 99,
      alpha: 1,
      icon: 'ic_map_marker.svg',
    };
    // 创建Marker
    this.marker = await this.mapController?.addMarker(markerOptions);
    if (this.marker) {
      // 设置信息窗的标题
      this.marker.setTitle(this.title);
      // 设置标记可点击
      this.marker.setClickable(true);
      // 设置信息窗的锚点位置
      this.marker.setInfoWindowAnchor(1, 0);
      // 设置信息窗可见
      this.marker?.setInfoWindowVisible(true);

    }

  }

  public handleClickGuide() {
    PopViewUtils.openDialog(
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
            destinationLatitude: this.hotelCoordinate.latitude,
            destinationLongitude: this.hotelCoordinate.longitude,
            destinationName: this.title,
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

@Builder
export function mapOptionsDialog() {
  Column({ space: 8 }) {
    Row() {
      Text('华为地图')
        .fontColor($r('app.color.font_color_link'))
    }
    .onClick(() => {
      LocationPageVM.instance.jumpToMapApp();
    })
    .optionContainerStyle();

    Row() {
      Text('取消')
        .fontColor($r('app.color.font_color_link'));
    }
    .optionContainerStyle()
    .onClick(()=> {
      PopViewUtils.closeDialog();
    })
  }
  .width($r('app.string.width_percent_full'))
  .margin({ bottom: $r('app.string.margin_l') });
}

@Extend(Row)
function optionContainerStyle() {
  .justifyContent(FlexAlign.Center)
  .backgroundColor($r('app.color.system_color_background_white'))
  .borderRadius(99)
  .padding($r('app.string.padding_m'))
  .width('90%');
}