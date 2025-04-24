import { GetCommodityOrderListResp, GetOrderDetailRequest, GetTicketOrderListResp, https } from 'network';
import { mapperCommodityOrderList, mapperTicketOrderList } from '../mapper/Index';
import { AppStorageV2 } from '@kit.ArkUI';
import { TICKET_ORDER_INFO_MAP } from '../model/TicketOrderInfo';
import { CommodityOrderInfo, TicketOrderInfo } from 'types';
import { COMMODITY_ORDER_INFO_MAP } from '../model/CommodityOrderInfo';
import { COMMODITY_ORDER_MODULE_INFO, TICKET_ORDER_MODULE_INFO } from '../model/OrderModuleInfo';

@ObservedV2
export class OrderPageVM {
  @Trace isFromMine: boolean = false;
  @Trace orderType: number = 0;
  @Trace orderTabIndex: number = 0;
  @Trace isLoading: boolean = false;
  @Trace ticketOrderList: GetTicketOrderListResp =
    AppStorageV2.connect(GetTicketOrderListResp, 'GetTicketOrderListResp',
      () => new GetTicketOrderListResp()) ?? [];
  @Trace commodityOrderList: GetCommodityOrderListResp =
    AppStorageV2.connect(GetCommodityOrderListResp, 'GetCommodityOrderListResp',
      () => new GetCommodityOrderListResp()) ?? [];
  public static _instance: OrderPageVM;

  public static get instance() {
    if (!OrderPageVM._instance) {
      OrderPageVM._instance = new OrderPageVM();
    }
    return OrderPageVM._instance;
  }

  getOrderStatus(item: TicketOrderInfo | CommodityOrderInfo) {
    return item.orderStatus;
  }

  getTicketStatus(item: TicketOrderInfo) {
    return TICKET_ORDER_INFO_MAP[item.orderStatus];
  }

  getTitle(index: number): ResourceStr {
    return this.orderType === 0 ? TICKET_ORDER_MODULE_INFO[index].title : COMMODITY_ORDER_MODULE_INFO[index].title;
  }

  getCommodityStatus(item: CommodityOrderInfo) {
    return COMMODITY_ORDER_INFO_MAP[item.orderStatus];
  }

  getOrderList() {
    this.isLoading = true;
    let param = {
      category: this.orderType,
      orderStatus: this.orderTabIndex,
    } as GetOrderDetailRequest;

    https.getOrderList(param).then((res: ESObject) => {
      if (this.orderType === 0) {
        this.ticketOrderList = mapperTicketOrderList(res.data);
      } else {
        this.commodityOrderList = mapperCommodityOrderList(res.data);
      }
      this.isLoading = false;
    });
  }
}