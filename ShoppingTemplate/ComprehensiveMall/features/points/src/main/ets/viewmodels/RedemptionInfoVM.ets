import { routerStack, WindowUtil } from 'lib_foundation'
import { PointsApis, RedemptionOrder } from 'lib_network'

@ObservedV2
export class RedemptionInfoVM {
  @Trace
  order: RedemptionOrder | undefined = undefined
  @Trace
  isLoading: boolean = false

  public async loadDetail(orderId: string) {
    this.isLoading = true
    const res = await PointsApis.getRedemptionDetail(orderId)
    if (res.code === 0) {
      this.order = res.data
    }
    this.isLoading = false
  }

  public async urgeShipment() {
    if (!this.order) {
      return
    }
    const res = await PointsApis.urgeRedemptionShipment(this.order.orderId)
    if (res.code === 0) {
      WindowUtil.toast('已催促发货，请耐心等待')
    }
  }

  public async confirmReceipt() {
    if (!this.order) {
      return
    }
    const res = await PointsApis.confirmRedemptionReceipt(this.order.orderId)
    if (res.code === 0) {
      WindowUtil.toast('确认收货成功')
      this.loadDetail(this.order.orderId)
    }
  }

  public async deleteOrder() {
    if (!this.order) {
      return
    }
    const res = await PointsApis.deleteRedemptionOrder(this.order.orderId)
    if (res.code === 0) {
      routerStack.pop(1)
    }
  }
}
