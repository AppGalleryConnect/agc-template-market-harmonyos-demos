import { map, mapCommon, site } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { AccommodationInfo, AttractionInfo, AttractionUtil, CateringInfo, Constant, ToiletInfo } from 'module_base';
import { Guide, LocationType } from '../model/GuideInfo';
import { GUIDE_TABS_INFO } from '../constants/Constant';
import { mapperToilet, mapSiteInfo } from '../mapper/Index';
import { UtilLog } from '@hw-agconnect/util-log';

@ObservedV2
export class AttractionGuideVM {
  // 默认展示景点列表
  @Trace guideInfo: Guide<AttractionInfo | CateringInfo | AccommodationInfo | ToiletInfo> = GUIDE_TABS_INFO[0];
  @Trace showDetail: boolean = false;
  @Trace distance: string = '';
  @Trace type: number = 0;
  @Trace selectedGuide: ESObject = AttractionUtil.getAttraction().attractions[0];
  @Trace attractionInfo: AttractionInfo[] = [];
  @Trace latitude: number = 0;
  @Trace longitude: number = 0;
  public static _instance: AttractionGuideVM;
  mapOptions?: mapCommon.MapOptions;
  callback?: AsyncCallback<map.MapComponentController>;
  mapController?: map.MapComponentController;
  mapEventManager?: map.MapEventManager;
  pointIds: string[] = [];

  public static get instance() {
    if (!AttractionGuideVM._instance) {
      AttractionGuideVM._instance = new AttractionGuideVM();
    }
    return AttractionGuideVM._instance;
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

    this.getPoiListByText(Constant.TOILET).then((res) => {
      let toiletList = mapperToilet(res.sites ?? [], this.latitude, this.longitude);
      // 本地存储卫生间信息
      AppStorage.setOrCreate('toiletList', toiletList);
    });

    if (!AppStorage.get('accommodationList')) {
      this.getPoiListByType(1, 'ACCOMMODATION').then((res) => {
        let accommodationSites = mapSiteInfo(res.sites ?? [], LocationType.ACCOMMODATION);
        AppStorage.setOrCreate('accommodationList', accommodationSites)!;
      });
    }
    if (!AppStorage.get('cateringList')) {
      this.getPoiListByType(1, 'RESTAURANT').then((res) => {
        let cateringSites = mapSiteInfo(res.sites ?? [], LocationType.CATERING);
        AppStorage.setOrCreate('cateringList', cateringSites)!;
      });
    }
  }

  initMapOptions(latitude: number, longitude: number) {
    let location = {
      target: {
        latitude: latitude,
        longitude: longitude,
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
          UtilLog.info(0x0000, 'AttractionGuideVM', `on-mapClick position = ${JSON.stringify(position)}`);
        });

        this.mapController.on('pointAnnotationClick', (pointAnnotation: map.PointAnnotation) => {
          let index: number = this.pointIds.indexOf(pointAnnotation.getId());
          this.selectedGuide = this.guideInfo.data[index];
          this.type = this.guideInfo.type;
          this.showDetail = true;
          UtilLog.info(0x0000, 'AttractionGuideVM',
            `on-PointAnnotationClick position = ${JSON.stringify(pointAnnotation)}`);
        });
        // 监听我的位置按钮
        this.mapEventManager?.on('myLocationButtonClick', locationButtonClick);
      }
    };
  }

  getPoiListByType(pageIndex: number, poiType: string, range?: number) {
    let params: site.NearbySearchParams = {
      // 指定关键字
      query: '',
      // 经纬度坐标
      location: {
        latitude: this.latitude,
        longitude: this.longitude,
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
      UtilLog.error(0x0000, 'AttractionGuideVM', `nearbySearch = ${JSON.stringify(e)}`);
    }

    return result
  }

  getPoiListByText(poiText: string, range?: number) {
    let params: site.SearchByTextParams = {
      query: poiText,
      location: {
        latitude: this.latitude,
        longitude: this.longitude,
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
      UtilLog.error(0x0000, 'AttractionGuideVM', `nearbySearch = ${JSON.stringify(e)}`);
    }

    return result
  }

  redrawScenes() {
    this.mapController?.clear();
    this.pointIds = [];
    this.drawBuilding();
  }

  async drawBuilding() {
    if (this.mapController) {
      let length: number = this.guideInfo.data.length;
      for (let i = 0; i < length; i++) {
        let locationItem: ESObject = this.guideInfo.data[i];
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
          icon: this.guideInfo.icon,
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
}