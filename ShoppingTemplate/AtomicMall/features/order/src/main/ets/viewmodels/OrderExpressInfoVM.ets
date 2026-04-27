import { AsyncCallback } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { mapCommon, map, navi } from '@kit.MapKit';
import { OrderApis, OrderExpressInfo, OrderItem } from 'lib_network';
import { UtilLog } from '@hw-agconnect/util-log';
import { CourierInfo, TextSegment } from '../common/Types';
import { OrderUtil } from '../utils/OrderUtil';

const DEFAULT_LATITUDE = 31.97;
const DEFAULT_LONGITUDE = 118.75;

@ObservedV2
export class OrderExpressInfoVM {
  @Trace
  loading: boolean = false;
  @Trace public offsetX: number = 0;
  @Trace public offsetY: number = 240;
  @Trace public positionX: number = 0;
  @Trace public positionY: number = 0;
  @Trace
  mapOptions?: mapCommon.MapOptions;
  @Trace
  mapController?: map.MapComponentController;
  @Trace
  mapEventManager?: map.MapEventManager;
  @Trace
  callback?: AsyncCallback<map.MapComponentController>;
  @Trace
  expressInfo?: OrderExpressInfo;
  @Trace
  orderItem?: OrderItem;
  @Trace
  courierInfo?:CourierInfo;
  private _uiContext: UIContext;

  constructor(uiContext: UIContext) {
    this._uiContext = uiContext;
  }

  public async initData(order: OrderItem) {
    this.orderItem = order;
    this.courierInfo = OrderUtil.getCourierInfo(order.logisticInfo);
    const res = await OrderApis.getExpressInfo(this.orderItem.orderInfo.orderNo);
    if (res.code === 0) {
      this.expressInfo = res.info;
    }
  }

  public initMap(func1: () => void, func2: () => void) {
    this.mapOptions = {
      position: {
        target: {
          latitude: DEFAULT_LATITUDE,
          longitude: DEFAULT_LONGITUDE,
        },
        zoom: 5,
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
        };
        this.mapEventManager.on('mapLoad', callback);
        setTimeout(() => {
          this.testDrivingRoutes();
          this.addPositionMarker();
          this.addMarkerCard(func1, func2);
        }, 500);
      }
    };
  }

  async testDrivingRoutes() {
    if (!this.expressInfo) {
      return;
    }
    let params: navi.DrivingRouteParams = {
      // 起点的经纬度
      origins: [this.expressInfo.origins],
      // 终点的经纬度
      destination: this.expressInfo.destination,
      // 路径的途经点
      waypoints: this.expressInfo.waypoints,
      language: 'zh_CN',
    };
    try {
      const result = await navi.getDrivingRoutes(params);
      await this.mapController?.addPolyline({
        points: result.routes[0].overviewPolyline,
        width: 16,
        color: 0xFFE64566,
      });
      UtilLog.info('Succeeded in getting driving routes.');
    } catch (err) {
      UtilLog.error('get driving routes failed. error: ' + JSON.stringify(err));
    }
  }

  async addPositionMarker() {
    let markerOptions1: mapCommon.MarkerOptions = {
      position: this.expressInfo!.origins,
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
    await this._addMarker(markerOptions1);

    let markerOptions2: mapCommon.MarkerOptions = {
      position: this.expressInfo!.destination,
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
    await this._addMarker(markerOptions2);
  }

  addMarkerCard(func1: () => void, func2: () => void) {
    this._uiContext.getComponentSnapshot().createFromBuilder(func1,
      async (error: Error, pixmap: image.PixelMap) => {
        if (error) {
          console.log('error: ' + JSON.stringify(error));
          return;
        }
        // Marker初始化参数
        let markerOptions: mapCommon.MarkerOptions = {
          position: this.expressInfo!.origins,
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
        this._addMarker(markerOptions);
      });

    this._uiContext.getComponentSnapshot().createFromBuilder(func2,
      async (error: Error, pixmap: image.PixelMap) => {
        if (error) {
          console.log('error: ' + JSON.stringify(error));
          return;
        }
        // Marker初始化参数
        let markerOptions: mapCommon.MarkerOptions = {
          position: this.expressInfo!.destination,
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
        this._addMarker(markerOptions);
      });
  }

  private async _addMarker(options: mapCommon.MarkerOptions) {
    try {
      await this.mapController?.addMarker(options);
    } catch (err) {
      UtilLog.error('add marker failed. error: ' + JSON.stringify(err));
    }
  }

  public splitTextByPhone(text: string): TextSegment[] {
    const PHONE_REGEX = /\d{3,4}-\d{7,8}|\d{11}/g;
    const result: TextSegment[] = [];
    let lastIndex = 0;

    text.replace(PHONE_REGEX, (match, offset: number) => {
      // 普通文本
      if (offset > lastIndex) {
        result.push({
          text: text.substring(lastIndex, offset),
          isPhone: false,
        });
      }
      // 电话号码
      result.push({
        text: match,
        isPhone: true,
      });

      lastIndex = offset + match.length;
      return match;
    });

    // 末尾文本
    if (lastIndex < text.length) {
      result.push({
        text: text.substring(lastIndex),
        isPhone: false,
      });
    }

    return result;
  }
}