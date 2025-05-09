import { OrderTypeComp } from '../components/OrderTypeComp'
import {
  DetailMoreCard,
  GoodsComp,
  HttpRequestApi,
  MakingCard,
  MapCard,
  MapLocation,
  MyOrderInfo,
  NavHeaderBar,
  OrderDetailRouter,
  OrderStateEnum,
  OrderTypeEnum,
  ReductionCard,
  RouterMap,
  StoreCard,
  StoreInfo,
  Utils,
  WindowModel,
} from 'common/Index'
import { BusinessError } from '@kit.BasicServicesKit'
import { mapCommon } from '@kit.MapKit'
import { application, common } from '@kit.AbilityKit'
import { AppStorageV2, promptAction } from '@kit.ArkUI'

@Builder
export function OrderDetailPageBuilder() {
  OrderDetailPage()
}

@ComponentV2
struct OrderDetailPage {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local orderId: string = ''
  @Local isOrderJump: boolean = false
  scroller: Scroller = new Scroller();
  @Local orderDetailInfo: MyOrderInfo = new MyOrderInfo()
  @Local storeInfo: StoreInfo = new StoreInfo()
  @Local selectStore: MapLocation = new MapLocation()
  @Local locations: Array<MapLocation> = []
  context?: common.Context;
  timer: number = 0

  getRouteParams() {
    let paramsArr: OrderDetailRouter[] =
      this.pageStack?.getParamByName(RouterMap.ORDER_DETAIL_PAGE) as OrderDetailRouter[]
    if (paramsArr.length) {
      this.orderId = paramsArr[paramsArr.length - 1].orderId
      this.isOrderJump = paramsArr[paramsArr.length - 1].isOrderJump
    }
  }

  initStoreInfo() {
    this.locations = []
    this.storeInfo.name = this.orderDetailInfo.order?.storeName ?? ''
    this.storeInfo.address = this.orderDetailInfo.order?.address ?? ''
    this.storeInfo.tel = this.orderDetailInfo.order?.tel ?? ''
    this.storeInfo.coordinates = this.orderDetailInfo.order?.coordinates ?? ''
    if (this.orderDetailInfo.order?.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY) {

      // 配送位置
      let location1 = new MapLocation()
      location1.id = '1'
      location1.latitude = this.orderDetailInfo.address.latitude
      location1.longitude = this.orderDetailInfo.address.longitude
      location1.icon = 'ic_user_location.png'
      this.locations.push(location1)
      // 店铺位置
      let location2 = new MapLocation()
      location1.id = '2'
      let locationArr2 = this.storeInfo.coordinates.split(',')
      if (locationArr2?.length === 2) {
        location2.title = this.orderDetailInfo.order?.storeName ?? ''
        location2.latitude = Number(locationArr2[0])
        location2.longitude = Number(locationArr2[1])
      }
      this.locations.push(location2)
      this.selectStore = location2
      // 外卖员位置
      if (this.orderDetailInfo.order.state === OrderStateEnum.DELIVERING) {
        let location3 = new MapLocation()
        location3.id = '3'
        location3.icon = 'ic_delivery_location.png'
        location3.latitude = this.orderDetailInfo.delivery.latitude
        location3.longitude = this.orderDetailInfo.delivery.longitude
        // 计算坐标之间的距离
        let fromLatLng: mapCommon.LatLng = {
          latitude: this.orderDetailInfo.delivery.latitude,
          longitude: this.orderDetailInfo.delivery.longitude,
        };
        let toLatLng: mapCommon.LatLng = {
          latitude: location1.latitude,
          longitude: location1.longitude,
        };
        let distance = Utils.getDistanceByLocation(fromLatLng, toLatLng)
        // 通过上下文获取字符串
        location3.title = this.context?.resourceManager.getStringByNameSync('delivery_distance',
          `${distance} ${this.orderDetailInfo.delivery.remainingTime}`) || ''
        this.locations.push(location3)
        this.selectStore = location3
      }
    }


    if (!this.timer && this.orderDetailInfo.order?.state &&
      this.orderDetailInfo.order?.state > OrderStateEnum.TO_BE_PAID) {
      this.timer = setInterval(() => {
        this.getOrderInfo()
      }, 5000)
    }
    if (this.orderDetailInfo.order?.state && this.orderDetailInfo.order?.state >= OrderStateEnum.COMPLETED) {
      clearInterval(this.timer)
    }
  }

  async aboutToAppear() {
    // 获取order_list上下文
    application.createModuleContext(getContext(), 'order_list').then((data: Context) => {
      this.context = data
    })
    this.getRouteParams()
    this.getOrderInfo()
  }

  getOrderInfo() {
    HttpRequestApi.getOrderInfo(this.orderId).then((resp: MyOrderInfo) => {
      if (resp) {
        console.info(`getOrderInfo resp:${JSON.stringify(resp)}.`);
        this.orderDetailInfo = resp
        this.initStoreInfo()
      } else {
        console.error(`getOrderInfo error: ${JSON.stringify(resp)}.`);
        promptAction.showToast({ message: $r('app.string.order_not_exist') })
        this.pageStack?.pop()
      }
    }).catch((e: BusinessError) => {
      console.error(`getOrderInfo error: ${JSON.stringify(e)}.`);
    })
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.order_detail') })
      Scroll(this.scroller) {
        Column({ space: 12 }) {
          OrderTypeComp({
            orderDetail: this.orderDetailInfo,
            orderState: this.orderDetailInfo.order?.state,
            getOrderInfo: () => {
              this.getOrderInfo()
            },
          })
          if (![OrderStateEnum.TO_BE_PAID, OrderStateEnum.CANCELED].includes(this.orderDetailInfo.order.state)) {
            MakingCard({
              orderState: this.orderDetailInfo.order?.state,
              orderType: this.orderDetailInfo.order?.orderType,
            })
          }
          if (this.orderDetailInfo.order?.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY &&
          [OrderStateEnum.MAKING, OrderStateEnum.DELIVERING].includes(this.orderDetailInfo.order.state)) {
            MapCard({
              locations: this.locations,
              selectStore: this.selectStore,
            })
          }
          StoreCard({ storeInfo: this.storeInfo })
          GoodsComp({ goodList: this.orderDetailInfo.good, bagMoney: this.orderDetailInfo.order.bagMoney })
          ReductionCard({ orderInfo: this.orderDetailInfo.order })
          DetailMoreCard({ orderInfo: this.orderDetailInfo })
        }
      }.layoutWeight(1)
      .padding({ bottom: this.windowModel.getWindowBottomHeight() })
    }
    .hideTitleBar(true)
    .backgroundColor('#F1F3F5')
    .onHidden(() => {
      clearInterval(this.timer)
    })
  }
}

