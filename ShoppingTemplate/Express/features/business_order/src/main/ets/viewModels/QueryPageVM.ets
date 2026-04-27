import {
  BaseViewModel,
  BreakpointNameEnum,
  HttpApi,
  Parcel,
  ParcelStatus,
  PayMethod,
  PayStatus,
  ToastLoading,
} from 'lib_foundation';
import { MOCK_RECEIVER_PHONE, FILTER_OPTIONS } from '../constants';
import { OrderInfo, TabBtnItem, TabBtnType } from '../models/Model';


@ObservedV2
export class QueryPageVM extends BaseViewModel {
  private static _instance: QueryPageVM;
  // tab
  @Trace tabBarList: TabBtnItem[] = [
    new TabBtnItem('寄件', 0, TabBtnType.SEND_EXPRESS),
    new TabBtnItem('收件', 0, TabBtnType.RECEIVE_EXPRESS),
    new TabBtnItem('待支付', 0, TabBtnType.PENDING_PAY),
  ]
  @Trace type: TabBtnType = TabBtnType.SEND_EXPRESS;
  // 选择tab的index
  @Trace selectedIndex: number = 0;
  // 全部订单
  @Trace allOrderList: OrderInfo[] = [];
  // 寄件订单
  @Trace sendOrderList: OrderInfo[] = [];
  // 收件订单
  @Trace receiveOrderList: OrderInfo[] = [];
  // 待支付订单
  @Trace pendingPayOrderList: OrderInfo[] = [];
  // 搜索文本
  @Trace searchText: string = '';
  // 筛选项列表
  @Trace filterData: SelectOption[] = FILTER_OPTIONS;
  // 筛选选择的状态
  @Trace selectedExpressStatus: string = '筛选';
  // 下拉刷新
  @Trace isRefreshing: boolean = false
  // 订单状态对应的过滤逻辑映射
  private statusMap: Record<string, (status: ParcelStatus) => boolean> = {
    '待取件': (s) => s === ParcelStatus.AWAITING_PICKUP,
    '待入柜': (s) => s === ParcelStatus.PENDING_LOCKER,
    '已取件': (s) => s === ParcelStatus.COLLECTED,
    '运送中': (s) => s === ParcelStatus.IN_TRANSIT,
    '派送中': (s) => s === ParcelStatus.DELIVERY,
    '待签收': (s) => s === ParcelStatus.OUT_FOR_DELIVERY,
    '已签收': (s) => s === ParcelStatus.DELIVERED,
    '已取消': (s) => s === ParcelStatus.CANCELED,
  };

  public static get instance() {
    if (!QueryPageVM._instance) {
      QueryPageVM._instance = new QueryPageVM();
    }
    return QueryPageVM._instance;
  }

  @Computed
  get waterFlowLanes() {
    const currentBreakpoint = this.breakPointModel.currentBreakpoint;
    switch (currentBreakpoint) {
      case BreakpointNameEnum.LG:
      case BreakpointNameEnum.XL:
        return 2;
      default:
        return 1;
    }
  }

  // 过滤方法
  filterOrders(list: OrderInfo[], isReceiveMode: boolean): OrderInfo[] {
    const searchText = this.searchText;
    const targetStatus = this.selectedExpressStatus;
    const tempList = list.filter((item: OrderInfo) => {
      // 判断是寄件人还是收件人
      const isIdentityMatch = isReceiveMode
        ? item.receiverPhone === MOCK_RECEIVER_PHONE
        : item.receiverPhone !== MOCK_RECEIVER_PHONE;

      if (!isIdentityMatch) {
        return false;
      }
      // 搜索词匹配
      const phoneToMatch = isReceiveMode ? item.receiverPhone : item.senderPhone;
      const isInclude = phoneToMatch.includes(searchText) || item.parcelNumber.includes(searchText);

      if (!isInclude) {
        return false;
      }
      // 状态匹配
      const statusFilter = this.statusMap[targetStatus];
      return statusFilter ? statusFilter(item.status) : true;
    });

    return tempList;
  }

  // 查询订单列表
  async queryOrderList(isSearch: boolean = true) {
    ToastLoading.open();
    // 运单列表页mock自动处理运单的物流轨迹状态, 只处理未签收和未取消的寄件订单
    const list = await HttpApi.queryParcelList();
    if (list.length) {
      const tasks = list
        .filter((item) => item.status < ParcelStatus.DELIVERED && item.receiverPhone !== MOCK_RECEIVER_PHONE)
        .map((item) => HttpApi.autoUpdateLogistics(item));
      // 并行执行所有请求
      await Promise.all(tasks);
    }
    // 重新查询列表数据
    HttpApi.queryParcelList().then(async (resp) => {
      // 这里的收件订单是mock插入的
      if (resp.length) {
        this.allOrderList = resp.map((item: Parcel) => new OrderInfo(item));
        if (isSearch) {
          this.handleSearchList();
        } else {
          // 寄件
          this.sendOrderList = this.filterOrders(this.allOrderList, false);
          // 收件
          this.receiveOrderList = this.filterOrders(this.allOrderList, true);
          // 待支付：寄件人且寄付现结且未支付  OR  收件人且到付且未支付
          this.pendingPayOrderList = this.allOrderList.filter((item) => {
            const isReceiver = (item.receiverPhone === MOCK_RECEIVER_PHONE ||
              item.receiverPhone === this.userInfoModel.phone);

            if (isReceiver) {
              return item.paymentStatus === PayStatus.PENDING && (item.receiverPhone.includes(this.searchText) ||
              item.parcelNumber.includes(this.searchText));
            } else {
              return item.paymentStatus === PayStatus.PENDING && item.status < ParcelStatus.DELIVERED &&
                item.payMethod === PayMethod.PREPAID && (item.senderPhone.includes(this.searchText) ||
              item.parcelNumber.includes(this.searchText));
            }
          });
          this.tabBarList[0].count = this.sendOrderList.length;
          this.tabBarList[1].count = this.receiveOrderList.length;
          this.tabBarList[2].count = this.pendingPayOrderList.length;
        }
      }
    }).finally(() => {
      this.isRefreshing = false;
      ToastLoading.close();
    })
  }

  handleSearchList() {
    // 寄件
    if (this.type === TabBtnType.SEND_EXPRESS) {
      this.sendOrderList = this.filterOrders(this.allOrderList, false);
      this.tabBarList[0].count = this.sendOrderList.length;
    } else if (this.type === TabBtnType.RECEIVE_EXPRESS) {
      // 收件
      this.receiveOrderList = this.filterOrders(this.allOrderList, true);
      this.tabBarList[1].count = this.receiveOrderList.length;
    } else if (this.type === TabBtnType.PENDING_PAY) {
      // 待支付
      this.pendingPayOrderList = this.allOrderList.filter((item) => {
        const isReceiver = (item.receiverPhone === MOCK_RECEIVER_PHONE ||
          item.receiverPhone === this.userInfoModel.phone);

        if (isReceiver) {
          return item.paymentStatus === PayStatus.PENDING && (item.receiverPhone.includes(this.searchText) ||
          item.parcelNumber.includes(this.searchText));
        } else {
          return item.paymentStatus === PayStatus.PENDING && item.status < ParcelStatus.DELIVERED &&
            item.payMethod === PayMethod.PREPAID && (item.senderPhone.includes(this.searchText) ||
            item.parcelNumber.includes(this.searchText));
        }
      });
      this.tabBarList[2].count = this.pendingPayOrderList.length;
    }
  }
}
