import { map, mapCommon, navi } from '@kit.MapKit';
import { AsyncCallback, BusinessError, emitter } from '@kit.BasicServicesKit';
import { paymentService } from '@kit.PaymentKit';
import { common } from '@kit.AbilityKit';
import {
  ExpressStatus,
  getOrderInfo,
  IOrderInfo,
  OrderType,
  RouterModule,
  ShippingMethod,
  updateOrder,
  UpdateOrderRequest,
} from 'lib_foundation';
import {
  getAddressData,
  Logger,
  RouterMap,
  sendAddressData,
  IAddrInfo,
  CommonUtil,
  toastUtil,
  contextUtil,
} from 'module_base';

const DEFAULT_LATITUDE = 31.97;
const DEFAULT_LONGITUDE = 118.75;

@ObservedV2
export class EditOrderPageVM {
  private static _instance: EditOrderPageVM;
  context: common.UIAbilityContext = contextUtil.getContext() as common.UIAbilityContext;
  @Trace public mapOptions?: mapCommon.MapOptions
  @Trace public mapController?: map.MapComponentController;
  @Trace public mapEventManager?: map.MapEventManager;
  @Trace public callback?: AsyncCallback<map.MapComponentController>
  @Trace public orderInfo: IOrderInfo | undefined
  @Trace public offsetX: number = 0;
  @Trace public offsetY: number = 240;
  @Trace public positionX: number = 0;
  @Trace public positionY: number = 0;
  @Trace public sendAddress: IAddrInfo = sendAddressData
  @Trace public getAddress: IAddrInfo = getAddressData
  @Trace public selectedAddress: OrderType = OrderType.SEND
  @Trace public isFresh: boolean = true
  @Trace public isEdit: boolean = false
  @Trace public showTip: boolean = true
  @Trace public showLoadingMask: boolean = true

  public static get instance() {
    if (!EditOrderPageVM._instance) {
      EditOrderPageVM._instance = new EditOrderPageVM();
    }
    return EditOrderPageVM._instance;
  }

  public init() {
    const param = RouterModule.getNavParam<number>({
      url: RouterMap.EDIT_ORDER_PAGE,
    });

    if (param && this.isFresh) {
      this.getOrderInfo(param)
    }
  }

  clear() {
    this.isEdit = false
    this.isFresh = true
    this.orderInfo = undefined
  }

  public async getOrderInfo(id: number) {
    const res = await getOrderInfo({ id })
    this.orderInfo = res
    this.sendAddress = this.orderInfo.sendAddress
    this.getAddress = this.orderInfo.getAddress
    this.orderInfo.destination = {
      latitude: this.orderInfo.origins.latitude - 0.01,
      longitude: this.orderInfo.origins.longitude - 0.03,
    }
    this.showLoadingMask = false
    this.testDrivingRoutes()
    this.addMarker()
  }

  public async updateOrder() {
    if (!this.orderInfo) {
      return
    }
    const address =
      this.sendAddress.province + this.sendAddress.city + this.sendAddress.district +
      this.sendAddress.street + this.sendAddress.detail
    const res = await CommonUtil.getAddressesFromLocationName(address)
    this.orderInfo.origins = {
      'latitude': res[0].latitude ?? 0,
      'longitude': res[0].longitude ?? 0,
    }
    this.mapController?.clear()
    this.addMarker()
    this.testDrivingRoutes()
    const data: UpdateOrderRequest = {
      id: this.orderInfo.id,
      sendAddress: this.sendAddress,
      getAddress: this.getAddress,
    }
    await updateOrder(data)
    let order: emitter.EventData = {
      data: {
        isFresh: true,
      },
    };
    try {
      emitter.emit('order', order);
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }
  }

  public async cancelOrder() {
    if (!this.orderInfo) {
      return
    }
    const data: UpdateOrderRequest = {
      id: this.orderInfo.id,
      expressStatus: ExpressStatus.CANCEL,
    }
    await updateOrder(data)
    let order: emitter.EventData = {
      data: {
        isFresh: true,
      },
    };
    try {
      emitter.emit('order', order);
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }
    RouterModule.pop()
    toastUtil.showToast('取消成功！');
  }

  public async prepay() {
    paymentService
      .requestPayment(this.context, '')
      .then(() => {
        Logger.info('succeeded in paying');
      })
      .catch((error: BusinessError) => {
        toastUtil.showToast('支付失败！');
        Logger.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
      });
  }

  public initMap() {
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
      optimize: true,
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
    let marker1: map.Marker | undefined
    let marker2: map.Marker | undefined
    if (this.orderInfo?.shippingMethod === ShippingMethod.PICK_UP_AT_HOME) {
      marker1 = await this.mapController?.addMarker({
        position: this.orderInfo?.destination,
        icon: $r('app.media.ic_people'),
      })

      marker2 = await this.mapController?.addMarker({
        position: this.orderInfo?.origins,
        icon: $r('app.media.ic_address'),
      })
    } else {
      marker1 = await this.mapController?.addMarker({
        position: this.orderInfo?.origins,
        icon: $r('app.media.ic_people'),
      })

      marker2 = await this.mapController?.addMarker({
        position: this.orderInfo?.destination,
        icon: $r('app.media.ic_service_point'),
      })
    }

    if (!marker1) {
      return
    }
    if (!marker2) {
      return
    }
    const res = this.orderInfo?.shippingMethod === ShippingMethod.PICK_UP_AT_HOME
    marker1.setTitle(res ? '嗨，很高兴为您服务' : '请自行前往服务点');
    // 设置信息窗的子标题
    marker1.setSnippet(res ? '我将按时上门取件' : '16点前投递快递员当日取件');
    // 设置标记可点击
    marker1.setClickable(true);
    // 设置信息窗的锚点位置
    marker1.setInfoWindowAnchor(0, 5);
    // 设置信息窗可见
    marker1.setInfoWindowVisible(true);
  }

  getTitle(value: ShippingMethod | undefined): string {
    if (!value) {
      return ''
    }
    if (value === ShippingMethod.PICK_UP_AT_HOME) {
      return '待上门取件'
    }
    return '待服务点自寄'
  }
}
