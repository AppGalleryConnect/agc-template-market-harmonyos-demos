import { map, mapCommon, MapComponent, sceneMap } from '@kit.MapKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, bundleManager, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import site from '@hms.core.map.site';
import { BaseTitle } from 'componentlib'


@Component
export struct TripView {
  context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  @State hideLocationButton: boolean = false
  @State userLatitude: number = 39.92194051376904
  @State userLongitude: number = 116.3971836796932
  @State userAddress: string | undefined = ''
  @State selectedLatitude: number = 39.92194051376904
  @State selectedLongitude: number = 116.3971836796932
  @State sheetHeight: number = 500;
  private TAG = 'HuaweiMapDemo';
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;

  // 校验应用是否被授予定位权限，可以通过调用checkAccessToken()方法来校验当前是否已经授权。
  async checkPermissions(): Promise<boolean> {
    const permissions: Array<Permissions> = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];
    for (let permission of permissions) {
      let grantStatus: abilityAccessCtrl.GrantStatus = await this.checkAccessToken(permission);
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        // 启用我的位置图层，mapController为地图操作类对象，获取方式详见显示地图章节
        this.mapController?.setMyLocationEnabled(true);
        // 启用我的位置按钮
        this.mapController?.setMyLocationControlsEnabled(true);
        return true;
      }
    }
    return false;
  }

  // 如果没有被授予定位权限，动态向用户申请授权
  requestPermissions(): void {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(getContext() as common.UIAbilityContext,
      ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'])
      .then((data: PermissionRequestResult) => {
        // 启用我的位置图层
        this.mapController?.setMyLocationEnabled(true);
      })
      .catch((err: BusinessError) => {
        console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
      })
  }

  async checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    // 获取应用程序的accessTokenID
    let tokenId: number = 0;
    let bundleInfo: bundleManager.BundleInfo =
      await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    console.info('Succeeded in getting Bundle.');
    let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    tokenId = appInfo.accessTokenId;

    // 校验应用是否被授予权限
    grantStatus = await atManager.checkAccessToken(tokenId, permission);
    console.info('Succeeded in checking access token.');
    return grantStatus;
  }

  async aboutToAppear(): Promise<void> {
    this.checkPermissions()
    this.requestPermissions()
    // 地图初始化参数，设置地图中心点坐标及层级
    this.mapOptions = {
      position: {
        target: {
          latitude: 39.9,
          longitude: 116.4
        },
        zoom: 10
      },

    };
    // 地图初始化的回调
    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapEventManager = this.mapController.getEventManager();
        let callback = () => {
          console.info(this.TAG, `on-mapLoad`);
        }
        this.mapEventManager.on('mapLoad', callback);
      }
    };
  }

  // 页面每次显示时触发一次，包括路由过程、应用进入前台等场景，仅@Entry装饰的自定义组件生效
  onPageShow(): void {
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

  @Builder
  TripTitleBuilder() {
    Text('出行导航')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    Column() {
      BaseTitle({
        customTitle: () => {
          this.TripTitleBuilder()
        }
      })

      Row() {
        Image($r('app.media.Search'))
          .width(13)
          .height(13)
          .margin({ left: 20 })
        Text('请输入地址')
          .fontSize(16)
          .fontColor($r('app.color.font_color_gray'))
          .margin({ left: 10 })
      }
      .width(328)
      .height(40)
      .borderRadius(24)
      .backgroundColor($r('app.color.search_color'))
      .borderRadius(20)
      .onClick(() => {
        geoLocationManager.getCurrentLocation().then((data) => {
          this.userLatitude = data.latitude
          this.userLongitude = data.longitude
        })
        let locationChoosingOptions: sceneMap.LocationChoosingOptions = {
          language: 'cn',
          // 展示搜索控件
          searchEnabled: true,
          // 展示附近Poi
          showNearbyPoi: true,
        }
        sceneMap.chooseLocation(getContext(this) as common.UIAbilityContext, locationChoosingOptions)
          .then(async (data) => {
            let params: site.ReverseGeocodeParams = {
              // 位置经纬度
              location: {
                latitude: this.userLatitude,
                longitude: this.userLongitude
              },
              language: 'cn',
              radius: 200
            }
            const result = await site.reverseGeocode(params).then((data) => {
              this.userAddress = '' +
                data.addressComponent.streetNumber?.streetName +
                data.addressComponent.streetNumber?.streetNumber
            })
            console.log('11111111111111' + JSON.stringify(data))
            this.selectedLatitude = data.location.latitude
            this.selectedLongitude = data.location.longitude
            const uri = this.context.resourceManager.getStringSync($r('app.string.navigateAddress')) +
            this.userLatitude +
              ',' +
            this.userLongitude +
              '(' + this.userAddress + ')' +
              '&daddr=' +
            data.location.latitude +
              ',' +
            data.location.longitude +
              '(' + data.name + ')' +
              '&type=bus&utm_source=fb';
            let context = getContext(this) as common.UIAbilityContext;
            context.openLink(uri, {
              appLinkingOnly: true
            });
          }).catch((err: BusinessError) => {
          console.error('ChooseLocation',
            `Failed to choose location, code: ${err.code},
            message: ${err.message}`);
        })

      })

      // 调用MapComponent组件初始化地图
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
        .width('100%')
        .height(580)
        .margin({ top: 16 })

    }
    .alignItems(HorizontalAlign.Center)
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.background_color'))
  }
}


// Haversine公式计算两点之间的距离
// function haversine(lat1: number, lon1: number, lat2: number, lon2: number): number {
//   const R = 6371; // 地球半径，单位为千米
//   // 转换为弧度
//   const radLat1 = toRadians(lat1);
//   const radLon1 = toRadians(lon1);
//   const radLat2 = toRadians(lat2);
//   const radLon2 = toRadians(lon2);
//
//   // 计算经纬度差值
//   const dLat = radLat2 - radLat1;
//   const dLon = radLon2 - radLon1;
//
//   // Haversine公式
//   const a = Math.sin(dLat / 2) ** 2 + Math.cos(radLat1) * Math.cos(radLat2) * Math.sin(dLon / 2) ** 2;
//   const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
//
//   // 计算距离
//   return R * c;
// }
// 辅助函数：将角度转换为弧度
// function toRadians(degrees: number): number {
//   return degrees * (Math.PI / 180);
// }
//
// function findNearestStation(userLatitude:number,userLongitude:number){
//
//   let minDistance = Infinity;
//   let nearestStation: Station|null = null;
//
//   for (const station of stations) {
//     const distance = haversine(userLatitude, userLongitude, station.latitude, station.longitude);
//     if (distance < minDistance) {
//       minDistance = distance;
//       nearestStation = station;
//     }
//   }
//
//   if (nearestStation) {
//     console.log(`最近的地铁站是: ${nearestStation.name}，距离: ${minDistance.toFixed(2)} km`);
//     return nearestStation
//   } else {
//     console.log('没有找到最近的地铁站');
//     return null
//   }
//
// }