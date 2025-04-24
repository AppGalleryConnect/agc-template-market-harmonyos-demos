import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { AccountUtil, CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@Builder
export function ShopMapBuilder() {
  ShopMap()
}

@ComponentV2
struct ShopMap {
  topRectHeight: number = 0;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private TAG = 'HuaweiMapDemo';
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;
  private marker?: map.Marker;
  private location:number[] = [39.9,116.4];

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
    let path:number[] = this.appPathStack.getParamByIndex(this.appPathStack.size() - 1) as number[];
    this.location = path;
    // 地图初始化参数，设置地图中心点坐标及层级
    this.mapOptions = {
      position: {
        target: {
          latitude: path[0],
          longitude: path[1]
        },
        zoom: 10
      }
    };

    // 地图初始化的回调
    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapEventManager = this.mapController.getEventManager();
        let callback = () => {
          this.setShopLocation()
        }
        this.mapEventManager.on('mapLoad', callback);
      }
    };
  }

  async setShopLocation() {
    // 获取用户位置坐标
    let location = await geoLocationManager.getCurrentLocation();
    location.latitude = this.location[0];
    location.longitude = this.location[1];
    // 设置用户的位置
    this.mapController && this.mapController.setMyLocation(location);
    let latLng: mapCommon.LatLng = {
      latitude: location.latitude,
      longitude: location.longitude
    };
    let cameraPosition: mapCommon.CameraPosition = {
      target: latLng,
      zoom: 15
    };
    // 新建CameraUpdate对象
    let cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    // 在1000ms内以动画的形式移动相机
    this.mapController && this.mapController.animateCamera(cameraUpdate, 1000);

    let markerOptions: mapCommon.MarkerOptions = {
      position: {
        latitude: location.latitude,
        longitude: location.longitude
      },
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: true,
      draggable: true,
      flat: false
    };
    // 创建Marker
    if (this.mapController) {
      this.marker = await this.mapController.addMarker(markerOptions);
    }

  }

  // 页面每次显示时触发一次，包括路由过程、应用进入前台等场景，仅@Entry装饰的自定义组件生效
  onPageShow(): void {
    AccountUtil.silentLogin();
    // 将地图切换到前台
    if (this.mapController) {
      this.mapController.show();
    }
  }

  // 页面每次隐藏时触发一次，包括路由过程、应用进入后台等场景，仅@Entry装饰的自定义组件生效
  onPageHide(): void {
    // 将地图切换到后台
    if (this.mapController) {
      this.mapController.hide();
    }
  }

  build() {
    NavDestination() {
      Stack() {
        // 调用MapComponent组件初始化地图
        MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
          .width(CommonConstants.FULL_WIDTH)
          .height(CommonConstants.FULL_HEIGHT);
      }.height(CommonConstants.FULL_HEIGHT)
    }
    .title('店铺位置')
    .margin({
      top: px2vp(this.topRectHeight)
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })
    .linearGradient({
      angle:135,
      colors:[['#D2E2F5', 0.0], ['#F1F3F5', 0.4]]
    })

  }
}