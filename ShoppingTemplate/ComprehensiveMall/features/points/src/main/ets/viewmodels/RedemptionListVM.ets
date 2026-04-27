import { RouterMap, routerStack, WindowUtil } from 'lib_foundation'
import { OrderItem, PointsApis, RedemptionOrder } from 'lib_network'
import { RedemptionOrderStatus } from '../commons/Enums'
import { buildPointsAddressSheetOptions } from '../utils/PointsAddressUtil'

@ObservedV2
export class RedemptionListVM {
  @Trace
  list: RedemptionOrder[] = []
  @Trace
  currentTabIndex: number = 0
  @Trace
  isLoading: boolean = false

  public async loadList(tabIndex: number = 0) {
    this.currentTabIndex = tabIndex
    this.isLoading = true
    // Tab 0: 全部；Tab 1-3: status 0-2
    if (tabIndex > 0) {
      const res = await PointsApis.getRedemptionList(tabIndex - 1)
      if (res.code === 0) {
        this.list = res.list
      }
    } else {
      const res = await PointsApis.getRedemptionList()
      if (res.code === 0) {
        this.list = res.list
      }
    }
    this.isLoading = false
  }

  public async urgeShipment(orderId: string) {
    const res = await PointsApis.urgeRedemptionShipment(orderId)
    if (res.code === 0) {
      WindowUtil.toast('已催促发货，请耐心等待')
    }
  }

  public async confirmReceipt(orderId: string) {
    const res = await PointsApis.confirmRedemptionReceipt(orderId)
    if (res.code === 0) {
      WindowUtil.toast('确认收货成功')
      this.loadList(this.currentTabIndex)
    }
  }

  public async deleteOrder(orderId: string) {
    const res = await PointsApis.deleteRedemptionOrder(orderId)
    if (res.code === 0) {
      this.loadList(this.currentTabIndex)
    }
  }

  public  navigateToExpress(order: RedemptionOrder): void {
    if (order.status !== RedemptionOrderStatus.PENDING_RECEIPT) {
      return;
    }
    const orderItemParam: OrderItem = {
      orderInfo: {
        status: 3,
        orderNo: order.orderId,
        addressInfo: order.addressInfo,
        orderTime: order.orderTime,
        originalPrice: order.product.price,
        finalPrice: order.product.price,
        discounts: [],
        receivingMethod: 1,
      },
      logisticInfo: order.logisticInfo ?? [],
      skuInfo: [],
    }
    routerStack.pushPath({ name: RouterMap.POINTS_EXPRESS_INFO, param: orderItemParam })
  }

  public  openAddressSheet(order: RedemptionOrder): void {
    const options = buildPointsAddressSheetOptions({
      originalAddress: order.addressInfo,
      orderId: order.orderId,
      handleSubmitSuccess: () => {
        this.loadList(this.currentTabIndex)
      },
    })
    routerStack.pushPath({
      name: RouterMap.UPDATE_ADDRESS,
      param: options,
    })
  }
}
