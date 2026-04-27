import { map, mapCommon, navi } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { INodeItem } from '../components/CommonTimeLine';
import { nodeListData } from '../constants';
import { getOrderInfo, IOrderInfo, RouterModule } from 'lib_foundation';
import { Logger, RouterMap } from 'module_base';
import { image } from '@kit.ImageKit';

const DEFAULT_LATITUDE = 31.97;
const DEFAULT_LONGITUDE = 118.75;

@ObservedV2
export class OrderInfoPageVM {
  private static _instance: OrderInfoPageVM;
  @Trace public mapOptions?: mapCommon.MapOptions
  @Trace public mapController?: map.MapComponentController;
  @Trace public mapEventManager?: map.MapEventManager;
  @Trace public callback?: AsyncCallback<map.MapComponentController>
  @Trace public orderInfo: IOrderInfo | undefined
  @Trace public nodeList: INodeItem[] = []
  @Trace public offsetX: number = 0;
  @Trace public offsetY: number = 240;
  @Trace public positionX: number = 0;
  @Trace public positionY: number = 0;
  @Trace public showLoadingMask: boolean = true
  @Trace uiContext: UIContext | null = null

  public static get instance() {
    if (!OrderInfoPageVM._instance) {
      OrderInfoPageVM._instance = new OrderInfoPageVM();
    }
    return OrderInfoPageVM._instance;
  }

  public init(func1: (() => ESObject), func2: (() => ESObject)) {
    const param = RouterModule.getNavParam<number>({
      url: RouterMap.ORDER_INFO_PAGE,
    });
    if (param) {
      this.getOrderInfo(param, func1, func2)
    }
  }

  clear() {
    this.orderInfo = undefined
  }

  public async getOrderInfo(id: number, func1: (() => ESObject), func2: (() => ESObject)) {
    const res = await getOrderInfo({ id })
    this.orderInfo = res
    this.nodeList = nodeListData.slice(0, this.orderInfo.logisticsInfo.length)
    for (let i = 0; i < this.nodeList.length; i++) {
      this.nodeList[i].time = this.orderInfo.logisticsInfo[i].time
      this.nodeList[i].description = this.orderInfo.logisticsInfo[i].content
    }
    this.nodeList.reverse()
    this.showLoadingMask = false
    this.testDrivingRoutes()
    this.addMarker()
    this.addMarkerCard(func1, func2)
  }

  public initMap(func1: (() => ESObject), func2: (() => ESObject)) {
    this.mapOptions = {
      position: {
        target: {
          latitude: DEFAULT_LATITUDE,
          longitude: DEFAULT_LONGITUDE,
        },
        zoom: 10,
      },
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
    };

    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapEventManager = this.mapController.getEventManager();
        let callback = () => {
          console.info('on-mapLoad');
        }
        this.mapEventManager.on('mapLoad', callback);
        this.testDrivingRoutes()
        this.addMarker()
        this.addMarkerCard(func1, func2)
      }
    };
  }

  async testDrivingRoutes() {
    if (!this.orderInfo) {
      return
    }
    let params: navi.DrivingRouteParams = {
      // 起点的经纬度
      origins: [this.orderInfo.origins],
      // 终点的经纬度
      destination: this.orderInfo.destination,
      // 路径的途经点
      waypoints: this.orderInfo.waypoints,
      language: 'zh_CN',
    };
    try {
      const result = await navi.getDrivingRoutes(params);
      this.mapController?.addPolyline({
        points: result.routes[0].overviewPolyline,
        width: 10,
        color: 0xFFFF2737,
      })
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }
  }

  async addMarker() {
    let markerOptions1: mapCommon.MarkerOptions = {
      position: this.orderInfo!.origins,
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 0,
      clickable: true,
      draggable: true,
      flat: false,
      icon: $r('app.media.ic_send_map'),
    };
    await this.mapController?.addMarker(markerOptions1)

    let markerOptions2: mapCommon.MarkerOptions = {
      position: this.orderInfo!.destination,
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 0,
      clickable: true,
      draggable: true,
      flat: false,
      icon: $r('app.media.ic_get_map'),
    };
    await this.mapController?.addMarker(markerOptions2)
  }

  addMarkerCard(func1: (() => ESObject) | void, func2: (() => ESObject) | void) {
    this.uiContext?.getComponentSnapshot().createFromBuilder(func1,
      async (error: Error, pixmap: image.PixelMap) => {
        if (error) {
          console.log('error: ' + JSON.stringify(error))
          return;
        }
        // Marker初始化参数
        let markerOptions: mapCommon.MarkerOptions = {
          position: this.orderInfo!.origins,
          rotation: 0,
          visible: true,
          zIndex: 0,
          alpha: 1,
          anchorU: 0.5,
          anchorV: 1,
          clickable: true,
          draggable: true,
          flat: false,
          icon: pixmap,
        };
        this.mapController?.addMarker(markerOptions);
      })

    this.uiContext?.getComponentSnapshot().createFromBuilder(func2,
      async (error: Error, pixmap: image.PixelMap) => {
        if (error) {
          console.log('error: ' + JSON.stringify(error))
          return;
        }
        // Marker初始化参数
        let markerOptions: mapCommon.MarkerOptions = {
          position: this.orderInfo!.destination,
          rotation: 0,
          visible: true,
          zIndex: 0,
          alpha: 1,
          anchorU: 0.5,
          anchorV: 1,
          clickable: true,
          draggable: true,
          flat: false,
          icon: pixmap,
        };
        this.mapController?.addMarker(markerOptions);
      })
  }
}
