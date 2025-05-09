import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common, Want } from '@kit.AbilityKit';
import { map, mapCommon, MapComponent } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { HwMapModel } from '../models/RouterModel';
import { CommonUrl, Constants } from '../constants/Common';
import { AppStorageV2 } from '@kit.ArkUI';
import { AppInfoModel, StoreInfoModel, WindowModel } from '../models/StorageModel';
import { RouterMap } from '../constants/RouterMap';

@Builder
export function HwMapBuilder() {
  HwMap()
}

@ComponentV2
export struct HwMap {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local latitude: number = 0
  @Local longitude: number = 0
  @Local mapController?: map.MapComponentController | undefined = undefined;
  @Local myLocation: geoLocationManager.Location | undefined = undefined;
  @Local isShowMyLocation: boolean = false;
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
          icon: 'ic_store_location.png',
        };
        // 创建Marker
        this.marker = await this.mapController.addMarker(markerOptions);
        this.mapController?.animateCamera(map.newLatLng({
          latitude: this.latitude,
          longitude: this.longitude,
        }, 15), 200);
      }
    };
  }

  getParams() {
    let paramsArr: HwMapModel[] = this.pageStack.getParamByName(RouterMap.HW_MAP) as HwMapModel[]
    if (paramsArr.length) {
      let routerParam = paramsArr[paramsArr.length-1]
      this.latitude = routerParam?.latitude ?? 0
      this.longitude = routerParam?.longitude ?? 0
    }
  }

  initPermission() {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();

    atManager.requestPermissionsFromUser(getContext(this) as common.UIAbilityContext,
      ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'])
      .then((data) => {
        let grantStatus: Array<number> = data.authResults;
        let length: number = grantStatus.length;
        for (let i = 0; i < length; i++) {
          if (grantStatus[i] === Constants.USER_GRANT_SUCCESS) {
            // 用户授权，可以继续访问目标操作
            this.isShowMyLocation = true
            this.getLocation(this.mapController).then((location: geoLocationManager.Location) => {
              console.info('my location' + JSON.stringify(location));
              this.myLocation = location;
              this.mapController?.setMyLocationEnabled(true);
              this.mapController?.setMyLocationControlsEnabled(true);
              this.mapController?.setZoomControlsEnabled(false);
            });

          }
        }
        // 授权成功
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
    let appInfo = AppStorageV2.connect(AppInfoModel) as AppInfoModel;
    let petalMapWant: Want = {
      bundleName: 'com.huawei.hmos.maps.app',
      uri: 'maps://routes',
      parameters: {
        linkSource: appInfo.packageName,
        destinationLatitude: this.latitude,
        destinationLongitude: this.longitude,
        destinationPoiId: '',
        destinationName: this.storeModel.storeInfo.address ?? '',
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
            Image($r('app.media.back'))
              .fillColor($r('sys.color.black'))
              .width(24)
              .height(24)
              .margin({ left: 13 })
              .onClick(() => {
                this.pageStack.pop()
              })
          }
          .width(Constants.FULL_SIZE)
          .margin({ top: this.windowModel.getWindowTopHeight() })
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
            .margin({ bottom: 12, right: 17 })
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
                Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.storeModel.storeInfo?.logo}`).width(40).height(40)
                Column() {
                  Text(this.storeModel.storeInfo?.name)
                    .fontSize(18)
                    .fontWeight(500)
                    .fontColor($r('sys.color.font_primary'))
                    .lineHeight(20)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(this.storeModel.storeInfo?.address)
                    .fontSize(12)
                    .fontColor('#9900000')
                    .lineHeight(14)
                    .margin({ top: 4 })
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }.alignItems(HorizontalAlign.Start).margin({ left: 11 }).layoutWeight(1)
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
    }.hideTitleBar(true).onShown(() => {
      if (this.mapController) {
        this.mapController.show();
      }
    }).onHidden(() => {
      if (this.mapController) {
        this.mapController.hide();
      }
    })

  }
}