import { map, mapCommon, MapComponent, navi } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { GuideVM } from '../viewmodel/GuideVM';
import { AttractionUtil, Constant, LocationUtil, Logger } from 'common';
import { LocationDetailModal } from '../components/LocationDetailModal';
import { Guide, GUIDE_TABS_INFO } from '../model/GuideInfo';
import { AccommodationInfo, AttractionInfo, CateringInfo, ToiletInfo } from 'types';
import { MediaService } from 'audio';
import { TitleBar } from 'components';

const TAG: string = '[GuideView]';

@Builder
export function GuideBuilder() {
  GuideView();
}

@ComponentV2
export struct GuideView {
  vm: GuideVM = GuideVM.instance;
  @Local type: number = 0;
  @Local showDetail: boolean = false;
  @Local routePaths: Array<navi.Route> = [];
  @Local showSheet: boolean = false;
  @Local showRoutes: boolean = false;
  @Local distance: string = '';
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Provider('selectedGuide') selectedGuide: ESObject = AttractionUtil.getAttraction().attractions[0];
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;
  private marker?: map.Marker;
  private pointIds: string[] = [];
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  aboutToAppear() {
    this.vm.initGuideInfo();
    this.initMapOptions();
  }

  initMapOptions() {
    let location = {
      target: {
        latitude: LocationUtil.getLocationInfo().latitude,
        longitude: LocationUtil.getLocationInfo().longitude,
      },
      zoom: 16,
    } as mapCommon.CameraPosition;

    this.mapOptions = {
      position: location,
      myLocationControlsEnabled: true,
      compassControlsEnabled: false,
      scaleControlsEnabled: true,
    };

    let locationButtonClick = () => {
      let cameraUpdate: map.CameraUpdate = map.newCameraPosition(location);
      // 1000ms内移动相机到mark点位置
      this.mapController?.animateCamera(cameraUpdate, 1000);
    };

    // 地图初始化的回调
    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapController.setBuildingEnabled(true);
        this.mapController?.setMyLocationEnabled(true);
        this.mapController.setDayNightMode(mapCommon.DayNightMode.AUTO);
        this.mapEventManager = this.mapController.getEventManager();
        this.drawBuilding();
        this.mapController.setMinZoom(2);
        this.mapController.setMaxZoom(18);
        this.mapController.on('mapClick', (position) => {
          Logger.info(TAG, `on-mapClick position = ${JSON.stringify(position)}`);
        });

        this.mapController.on('pointAnnotationClick', (pointAnnotation: map.PointAnnotation) => {
          // 释放播控资源
          MediaService.getInstance().releaseAvPlayer();
          let index: number = this.pointIds.indexOf(pointAnnotation.getId());
          this.selectedGuide = this.vm.guideInfo.data[index];
          this.type = this.vm.guideInfo.type;
          this.showDetail = true;
          Logger.info(TAG, `on-PointAnnotationClick position = ${JSON.stringify(pointAnnotation)}`);
        });

        // 监听我的位置按钮
        this.mapEventManager?.on('myLocationButtonClick', locationButtonClick);
      }
    };
  }

  redrawScenes() {
    this.mapController?.clear();
    this.pointIds = [];
    this.drawBuilding();
  }

  async drawBuilding() {
    if (this.mapController) {
      let length: number = this.vm.guideInfo.data.length;
      for (let i = 0; i < length; i++) {
        let locationItem: ESObject = this.vm.guideInfo.data[i];
        let title: string = locationItem.name;
        let pointAnnotationOptions: mapCommon.PointAnnotationParams = {
          position: {
            latitude: locationItem.latitude,
            longitude: locationItem.longitude,
          },
          repeatable: true,
          collisionRule: mapCommon.CollisionRule.NAME,
          titles: [{
            content: title,
            fontSize: 12,
            strokeColor: 0xFFFFFFFF,
            strokeWidth: 2,
            fontStyle: mapCommon.FontStyle.BOLD,
          },
          ],
          icon: this.vm.guideInfo.icon,
          showIcon: true,
          forceVisible: false,
          minZoom: (i === 0 ? 2 : 14),
          maxZoom: 18,
          visible: true,
          zIndex: 5,
        };
        let pointAnnotation = await this.mapController.addPointAnnotation(pointAnnotationOptions);
        this.pointIds.push(pointAnnotation.getId());
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: false, title: '导览', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Stack({ alignContent: Alignment.BottomStart }) {
          Stack({ alignContent: Alignment.TopStart }) {
            MapComponent({
              mapOptions: this.mapOptions,
              mapCallback: this.callback,
            }).width(Constant.FULL_PERCENT);

            Row() {
              ForEach(GUIDE_TABS_INFO,
                (item: Guide<AttractionInfo | CateringInfo | AccommodationInfo | ToiletInfo>, index: number) => {
                  Column() {
                    Image(this.type === index ? item.activeIcon : item.defaultIcon).size({ height: 48, width: 48 });
                    Text(item.title).margin({ top: 8 }).fontSize(12);
                  }.onClick(() => {
                    // 释放播控资源
                    MediaService.getInstance().releaseAvPlayer();
                    this.vm.guideInfo = GUIDE_TABS_INFO[index];
                    this.type = index;
                    this.vm.changeGuideInfo(index);
                    this.showDetail = false;
                    // 重新绘制地图
                    this.redrawScenes();
                  });
                }, (item: Guide<AttractionInfo | CateringInfo | AccommodationInfo | ToiletInfo>) => item.title);
            }
            .padding(16)
            .backgroundColor(Color.White)
            .width(Constant.FULL_PERCENT)
            .justifyContent(FlexAlign.SpaceBetween);
          };

          if (this.showDetail) {
            Column() {
              LocationDetailModal({
                showDetail: this.showDetail,
                distance: this.distance,
                type: this.type,
                close: () => {
                  this.showDetail = false;
                },
              });
            }.padding(12).margin({ bottom: 32 });
          }
        }.height('90%');
      }.height(Constant.FULL_PERCENT);
    }.hideTitleBar(true);
  }
}