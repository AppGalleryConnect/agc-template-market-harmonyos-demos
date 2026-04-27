import { AppStorageV2 } from '@kit.ArkUI';
import { Constants, GlobalContext } from 'common';
import { MyOrderList, OrderInfo, OrderStatus } from 'common_travel_guide';


@ObservedV2
export class OrderPageVM {
  @Trace orderList: MyOrderList = AppStorageV2.connect(MyOrderList, () => new MyOrderList())!
  @Trace currentIndexTab: number = 0;
  @Trace untraveledOrderList: OrderInfo[] = []
  @Trace pendingOrderList: OrderInfo[] = []
  ctx: UIContext = GlobalContext.getUIContext();

  getLocalList() {
    this.untraveledOrderList =
      this.orderList.list.filter(item => [OrderStatus.BOOKED, OrderStatus.ISSUED].includes(item.status))
    this.pendingOrderList = this.orderList.list.filter(item => item.status === OrderStatus.PENDING)
  }

  getListByIndex(index: number) {
    switch (index) {
      case Constants.TAB_INDEX_ZERO:
        return this.orderList.list
      case Constants.TAB_INDEX_ONE:
        return this.pendingOrderList
      case Constants.TAB_INDEX_TWO:
        return this.untraveledOrderList
    }
    return this.orderList.list
  }

  deleteItem(id: string) {
    this.ctx.showAlertDialog({
      title: '您需要删除此订单吗？',
      message: '删除后无法在客户端查询订单及开票记录，无法对订单进行后续操作，请谨慎操作',
      width: 328,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          fontColor: 'rgba(0, 0, 0, 0.50)',
          action: () => {
          }
        },
        {
          value: '确认',
          action: () => {
            this.orderList.deleteById(id)
            this.getLocalList()
          }
        }
      ]
    })
  }
}