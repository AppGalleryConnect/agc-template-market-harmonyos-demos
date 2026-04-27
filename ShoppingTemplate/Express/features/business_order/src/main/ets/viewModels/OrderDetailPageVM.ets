import { map, mapCommon } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import {
  RouterModule,
  Logger,
  RouterMap,
  CommonUtil,
  HttpApi,
  Parcel,
  ParcelStatus,
  TelUtil,
  BaseViewModel,
  PAY_METHOD_LIST,
  ShippingType,
  CommonDialogUtil,
  DEFAULT_LATITUDE,
  DEFAULT_LONGITUDE,
} from 'lib_foundation';
import { ActionMenuItem } from '../models/Model';
import { AddressInfoModel } from 'module_template';

@ObservedV2
export class OrderDetailPageVM extends BaseViewModel {
  // 订单号
  @Trace orderNo: string = '';
  @Trace mapOptions?: mapCommon.MapOptions
  @Trace mapController?: map.MapComponentController;
  @Trace mapEventManager?: map.MapEventManager;
  @Trace callback?: AsyncCallback<map.MapComponentController>;
  @Trace origin?: mapCommon.LatLng;
  @Trace destination?: mapCommon.LatLng;
  @Trace orderInfo: Parcel = new Parcel();
  // 寄件人信息
  @Trace senderInfo: AddressInfoModel = new AddressInfoModel();
  // 收件人信息
  @Trace receiverInfo: AddressInfoModel = new AddressInfoModel();
  // 物品名称
  @Trace goodsName: string = '';
  // 快递公司
  @Trace expressName: string = '';
  // 付款方式
  @Trace payMethodText: string = '';
  // 格口
  @Trace gridText: string = '';
  @Trace showTip: boolean = true
  @Trace showLoadingMask: boolean = true;
  @Trace actionMenuList: ActionMenuItem[] = [
    {
      label: '修改信息',
      icon: $r('sys.symbol.square_and_pencil_fill'),
      action: () => {
        RouterModule.push({ url: RouterMap.EDIT_ORDER_PAGE, param: this.orderNo })
      },
    },
    {
      label: '取消寄件',
      icon: $r('sys.symbol.xmark_circle_fill'),
      action: () => {
        CommonDialogUtil.open({ content: '确定要取消寄件吗？'}, () => {
          this.cancelOrder();
        })
      },
    },
    {
      label: '联系快递员',
      icon: $r('sys.symbol.phone_fill'),
      action: () => {
        TelUtil.makeCall('联系快递员', '0012356');
      },
    },
  ]

  initData() {
    const param = RouterModule.getNavParam<string>({ url: RouterMap.ORDER_DETAIL });
    if (param) {
      this.orderNo = param;
      this.queryOrderInfo();
    }
  }

  // 地图初始化
  initMap() {
    this.mapOptions = {
      position: {
        target: {
          latitude: DEFAULT_LATITUDE,
          longitude: DEFAULT_LONGITUDE,
        },
        zoom: 15,
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
          Logger.info('on-mapLoad');
        }
        this.mapEventManager.on('mapLoad', callback);
      }
    };
  }

  queryOrderInfo() {
    this.showLoadingMask = true;
    HttpApi.queryParcelDetail(this.orderNo).then((resp) => {
      if (resp.detail) {
        this.orderInfo = resp.detail;
        this.initShippingInfo();
        this.getLocationData();
      }
    }).finally(() => {
      this.showLoadingMask = false;
    })
  }

  // 获取经纬度
  getLocationData() {
    // 寄件人位置
    this.origin = {
      latitude: this.orderInfo.senderLatitude,
      longitude: this.orderInfo.senderLongitude,
    };
    if (this.orderInfo.status === ParcelStatus.CANCELED) {
      this.mapController?.clear();
    } else {
      // mock 随机生成快递员的位置
      this.destination = {
        latitude: this.origin.latitude - 0.004,
        longitude: this.origin.longitude - 0.005,
      }
    }
    this.tryRenderMarkers();
  }

  initShippingInfo() {
    // 寄件/收件人信息
    this.senderInfo.addressId = this.orderInfo.senderAddressId;
    this.senderInfo.name = this.orderInfo.senderName;
    this.senderInfo.phone = this.orderInfo.senderPhone;
    this.senderInfo.fullAddress = this.orderInfo.senderFullAddress;
    this.senderInfo.province = this.orderInfo.senderProvince;
    this.senderInfo.city = this.orderInfo.senderCity;
    this.receiverInfo.addressId = this.orderInfo.receiverAddressId;
    this.receiverInfo.name = this.orderInfo.receiverName;
    this.receiverInfo.phone = this.orderInfo.receiverPhone;
    this.receiverInfo.fullAddress = this.orderInfo.receiverFullAddress;
    this.receiverInfo.province = this.orderInfo.receiverProvince;
    this.receiverInfo.city = this.orderInfo.receiverCity;
    // 物品名称
    this.goodsName = this.orderInfo.goodsName;
    // 快递名称
    this.expressName = this.orderInfo.expressCompany;
    // 付款方式
    this.payMethodText = PAY_METHOD_LIST.find((item) => item.value === this.orderInfo.payMethod)!.text;
    // 格口
    this.gridText = this.orderInfo.grid;
  }

  tryRenderMarkers() {
    if (this.mapController && this.origin) {
      let cameraPosition: mapCommon.CameraPosition = {
        target: this.origin,
        zoom: 15
      };
      // 新建CameraUpdate对象
      let cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
      // 移动相机
      this.mapController!.moveCamera(cameraUpdate);
      this.addMarker();
    }
  }

  async addMarker() {
    const isCancel = this.orderInfo.status === ParcelStatus.CANCELED;
    const isPickUp = this.orderInfo.shippingMethod === ShippingType.PICKUP_SERVICE;
    let marker1: map.Marker | undefined;
    let marker2: map.Marker | undefined;
    if (isCancel) {
      marker1 = await this.mapController?.addMarker({
        position: this.origin,
        icon: $r('app.media.ic_receive_map'),
      })
    } else {
      if (isPickUp) {
        marker1 = await this.mapController?.addMarker({
          position: this.origin,
          icon: $r('app.media.ic_address'),
        })

        marker2 = await this.mapController?.addMarker({
          position: this.destination,
          icon: $r('app.media.ic_people'),
        })
      } else {
        marker1 = await this.mapController?.addMarker({
          position: this.origin,
          icon: $r('app.media.ic_address'),
        })

        marker2 = await this.mapController?.addMarker({
          position: this.destination,
          icon: $r('app.media.ic_service_point'),
        })
      }
    }

    if (isCancel) {
      if (!marker1) {
        return
      }
    } else {
      if (!marker1 || !marker2) {
        return
      }
    }
    let marker = isCancel ? marker1 : marker2;
    let title = isPickUp ? '嗨，很高兴为您服务' : '请自行前往服务点';
    title = isCancel ? '已取消寄件' : title;
    let subTitle = isPickUp ? '我将按时上门取件' : '16点前投递快递员当日取件';
    subTitle = isCancel ? '' : subTitle;
    marker!.setTitle(title);
    marker!.setSnippet(subTitle);
    // 设置标记可点击
    marker!.setClickable(true);
    // 设置信息窗的锚点位置
    marker!.setInfoWindowAnchor(0, 5);
    // 设置信息窗可见
    marker!.setInfoWindowVisible(true);
  }

  getStateText(): string {
    if (this.orderInfo.status === ParcelStatus.CANCELED) {
      return '已取消';
    }
    if (this.orderInfo.shippingMethod === ShippingType.PICKUP_SERVICE) {
      return '待上门取件';
    }
    return '待服务点自寄';
  }

  getSubTitle(): string {
    // 已取消
    if (this.orderInfo.status === ParcelStatus.CANCELED) {
      return `取消时间：${CommonUtil.formatDate(this.orderInfo.cancelTime, 'MM月DD日 HH:mm')}`;
    }
    if (this.orderInfo.shippingMethod === ShippingType.PICKUP_SERVICE) {
      return `预计${CommonUtil.parsePickupTime(this.orderInfo.pickupTime)}上门取件`
    }
    return '请于晚上8点前前往服务点'
  }

  // 取消订单
  public async cancelOrder() {
    const nowTime = Date.now()
    const data = {
      id: this.orderInfo.id,
      parcelNumber: this.orderInfo.parcelNumber,
      status: ParcelStatus.CANCELED,
      cancelTime: nowTime,
      updateTime: nowTime,
    } as Parcel
    HttpApi.updateOrder(data).then((resp) => {
      if (resp) {
        ToastDialog.showToast({ message: '取消成功！' });
        if (this.orderInfo.couponId) {
          HttpApi.refundCoupon(this.userInfoModel.id, this.orderInfo.couponId);
        }
        this.queryOrderInfo();
      }
    })
  }
}
