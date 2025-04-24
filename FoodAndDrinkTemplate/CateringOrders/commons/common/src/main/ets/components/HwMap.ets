import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common, Want } from '@kit.AbilityKit';
import { map, mapCommon, MapComponent } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { StoreInfo } from '../models/ResponseModel';
import { HwMapModel } from '../models/RouterModel';
import { CommonUrl, Constants } from '../constants/Common';

@Component
export struct HwMap {
  @Consume('pageStack') pageStack: NavPathStack
  @State windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77
  @State latitude: number = 0
  @State longitude: number = 0
  @State storeInfo?: StoreInfo = undefined
  @State mapController?: map.MapComponentController | undefined = undefined;
  @State myLocation: geoLocationManager.Location | undefined = undefined;
  @State isShowMyLocation: boolean = false;
  private marker?: map.Marker;
  private mapOption?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private style: mapCommon.MyLocationStyle = {
    anchorU: 0.5,
    anchorV: 0.5,
    radiusFillColor: 0xff00FFFFFF,
    displayType: mapCommon.MyLocationDisplayType.FOLLOW,
  };

  aboutToAppear(): void {
    this.getParams()
    this.initPermission()
    this.mapOption = {
      position: {
        target: {
          latitude: this.latitude,
          longitude: this.longitude,
        },
        zoom: 15,
      },
    };

    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapController.on('mapLoad', () => {
          console.info('mapLoad success');
        });
        this.abilityEnabled();
        mapController.setMyLocationStyle(this.style);
        if (this.isShowMyLocation) {
          this.getLocation(this.mapController).then((location: geoLocationManager.Location) => {
            console.info('my location' + JSON.stringify(location));
            this.myLocation = location;
          });
        }
        // Marker初始化参数
        let markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: this.latitude,
            longitude: this.longitude,
          },
          rotation: 0,
          visible: true,
          zIndex: 0,
          alpha: 1,
          anchorU: 0.5,
          anchorV: 1,
          clickable: true,
          draggable: true,
          flat: false,
        };
        // 创建Marker
        this.marker = await this.mapController.addMarker(markerOptions);
        await this.marker.setIcon($r('app.media.store_location'));
        this.mapController?.animateCamera(map.newLatLng({
          latitude: this.latitude,
          longitude: this.longitude,
        }, 15), 200);
      }
    };
  }

  getParams() {
    let paramsArr: HwMapModel[] = this.pageStack.getParamByName('HwMap') as HwMapModel[]
    if (paramsArr.length) {
      let routerParam = paramsArr[paramsArr.length-1]
      this.latitude = routerParam?.latitude ?? 0
      this.longitude = routerParam?.longitude ?? 0
      this.storeInfo = routerParam?.storeInfo ?? undefined
    }
  }

  initPermission() {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();

    atManager.requestPermissionsFromUser(getContext(this) as common.UIAbilityContext,
      ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'])
      .then((data) => {
        let grantStatus: Array<number> = data.authResults;
        // 用户授权，可以继续访问目标操作
        this.isShowMyLocation = grantStatus.every(item => item === Constants.USER_GRANT_SUCCESS)
        if (this.isShowMyLocation) {
          // 授权成功
          this.getLocation(this.mapController).then((location: geoLocationManager.Location) => {
            console.info('my location' + JSON.stringify(location));
            this.myLocation = location;
            this.mapController?.setMyLocationEnabled(true);
            this.mapController?.setMyLocationControlsEnabled(true);
            this.mapController?.setZoomControlsEnabled(false);
          });
        }

      }).catch((err: BusinessError) => {
      console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
    });
  }

  async abilityEnabled(): Promise<void> {
    if (this.isShowMyLocation) {
      this.mapController?.setMyLocationEnabled(true);
      this.mapController?.setMyLocationControlsEnabled(true);
    }
    this.mapController?.setZoomControlsEnabled(false);
  }

  getLocation(mapController?: map.MapComponentController): Promise<geoLocationManager.Location> {
    let promise = geoLocationManager.getCurrentLocation();
    console.info('getCurrentLocation' + JSON.stringify(promise));
    promise.then(async (location: geoLocationManager.Location) => {
      mapController?.setMyLocation(location);
      console.info('getCurrentLocation' + JSON.stringify(location));
      return location;
    }).catch((error: Error) => {
      console.error('getCurrentLocation failed', 'getCurrentLocation error: ' + JSON.stringify(error));
    });
    return promise;
  }

  goPetalMap() {
    let petalMapWant: Want = {
      bundleName: 'com.huawei.hmos.maps.app',
      uri: 'maps://routes',
      parameters: {
        linkSource: AppStorage.get('packageName') as string,
        destinationLatitude: this.latitude,
        destinationLongitude: this.longitude,
        destinationPoiId: '',
        destinationName: this.storeInfo?.address ?? '',
      },
    }

    let context = getContext(this) as common.UIAbilityContext;
    context.startAbility(petalMapWant);
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.BottomStart }) {
        RelativeContainer() {
          MapComponent({ mapOptions: this.mapOption, mapCallback: this.callback })
          Row() {
            Row() {
              Image($r('app.media.back')).width(24).height(24)
            }
            .width(40)
            .height(40)
            .backgroundColor('#0C000000')
            .padding(8)
            .borderRadius(1000)
            .margin({ left: 13 })
            .onClick(() => {
              this.pageStack.pop()
            })

          }
          .width(Constants.FULL_SIZE)
          .margin({ top: this.windowTopHeight })
          .constraintSize({ maxWidth: Constants.FULL_SIZE })
          .padding({ bottom: 10, top: 16 })
          .justifyContent(FlexAlign.Start)
          .alignRules({
            'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
            'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start },
            'right': { 'anchor': '__container__', 'align': HorizontalAlign.End },
          })


          Image($r('app.media.my_location'))
            .width(32)
            .height(32)
            .borderRadius(8)
            .margin({ bottom: 24, right: 16 })
            .alignRules({
              'bottom': { 'anchor': 'bottomCol', 'align': VerticalAlign.Top },
              'right': { 'anchor': '__container__', 'align': HorizontalAlign.End },
            })
            .onClick(() => {
              if (this.myLocation) {
                this.mapController?.animateCamera(map.newLatLng({
                  latitude: this.myLocation?.latitude,
                  longitude: this.myLocation?.longitude,
                }, 15), 200);
              }
            })
          Column() {
            Row() {
              Row() {
                Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.storeInfo?.logo}`).width(40).height(40).borderRadius(8)
                Column() {
                  Text(this.storeInfo?.name)
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(this.storeInfo?.address)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: 2 })
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }.alignItems(HorizontalAlign.Start).margin({ left: 8 }).layoutWeight(1)
              }.layoutWeight(1)

              Image($r('app.media.navigation')).width(40).onClick(() => {
                this.goPetalMap()
              })
            }
            .width(Constants.FULL_SIZE)
            .justifyContent(FlexAlign.SpaceBetween)

          }
          .width(Constants.FULL_SIZE)
          .borderRadius({ topLeft: 20, topRight: 20 })
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .padding({
            top: 30,
            left: 24,
            right: 24,
            bottom: 30,
          })
          .alignRules({
            'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
            'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start },
            'right': { 'anchor': '__container__', 'align': HorizontalAlign.End },
          })
          .id('bottomCol')
        }.height(Constants.FULL_SIZE)

      }
    }.hideTitleBar(true)

  }
}