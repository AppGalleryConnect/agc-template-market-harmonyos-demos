import { RouterMap, routerStack } from 'lib_foundation';
import { OrderApis, OrderItem } from 'lib_network';
import { ORDER_TAB_LIST } from '../common/Constants';
import { OrderActionMap, OrderStatusMap, OrderTabsMap } from '../common/Enums';
import { OrderUtil } from '../utils/OrderUtil';
import { buildOrderAddressSheetOptions } from '../views/UpdateAddressSheet';

@ObservedV2
export class OrderListPageVM {
  @Trace
  isLoading: boolean = false;
  @Trace
  isRefreshing: boolean = false;
  @Trace
  currentIndex: number = 0;
  @Trace
  orderList: OrderItem[] = [];
  @Trace
  curPage: number = 1;
  @Trace
  totalNum: number = 0;
  @Trace
  reachEnd: boolean = false;
  @Trace
  reviewTabIndex: number = 0;
  @Trace
  keywords: string = '';
  searchController: SearchController = new SearchController();
  tabController: TabsController = new TabsController();
  listScroller: Scroller = new Scroller();

  public async initOrderTab(index: number) {
    this.currentIndex = index;
    this.tabController.changeIndex(index);
    this.isLoading = true;
    await this.getOrderList();
    this.isLoading = false;
  }

  public async changeTab(index: number) {
    this.currentIndex = index;
    this.orderList = [];
    this.refreshOrderList();
  }

  public switchReviewTab(index: number) {
    this.reviewTabIndex = index;
    this.refreshOrderList();
  }

  public async refreshOrderList() {
    this.reachEnd = false;
    this.curPage = 1;
    this.totalNum = 0;
    await this.getOrderList(true);
  }

  public async getOrderList(isRefresh: boolean = false, keywords?: string) {
    if (this.reachEnd || this.isRefreshing) {
      return;
    }
    if (isRefresh) {
      this.isRefreshing = true;
    }
    let status: number[] = [];
    if (this.currentIndex === OrderTabsMap.REVIEW) {
      status =
        this.reviewTabIndex === 0
          ? [OrderStatusMap.PENDING_REVIEW]
          : [OrderStatusMap.REVIEWED];
    } else {
      status = ORDER_TAB_LIST[this.currentIndex].statusInfo.map(
        (item) => item.status,
      );
    }
    const res = await OrderApis.getList(this.curPage, status, keywords);
    if (res.code === 0) {
      this.totalNum = res.total;
      if (isRefresh) {
        this.orderList = [];
      }
      this.orderList.push(...res.orderList);
      if (this.curPage * 6 >= this.totalNum) {
        this.reachEnd = true;
      }
      this.curPage++;
    }
    this.isRefreshing = false;
  }

  public handleOrderItem(orderItem: OrderItem, action: OrderActionMap) {
    if (action === OrderActionMap.UPDATE_ADDRESS) {
      routerStack.pushPath(
        {
          name: RouterMap.ORDER_UPDATE_ADDRESS,
          param: buildOrderAddressSheetOptions({
            originalAddress: orderItem.orderInfo.addressInfo,
            orderNo: orderItem.orderInfo.orderNo,
            handleSubmitSuccess: () => {
              routerStack.pop();
              this.refreshOrderList();
            },
          }),
        },
        false,
      );
    } else if (action === OrderActionMap.REVIEW) {
      routerStack.pushPath({
        name: RouterMap.ORDER_REVIEW_CREATE,
        param: orderItem,
        onPop: () => {
          this.refreshOrderList();
        },
      });
    } else if (action === OrderActionMap.REORDER) {
      const skuList = orderItem.skuInfo;
      OrderUtil.handleReorder({
        orderNo: orderItem.orderInfo.orderNo,
        data: skuList,
      });
    } else if (action === OrderActionMap.VIEW_REVIEW) {
      OrderUtil.handleViewReview({
        orderNo: orderItem.orderInfo.orderNo,
        data: orderItem,
      });
    } else {
      OrderUtil.handleOrderAction(action, {
        orderNo: orderItem.orderInfo.orderNo,
        data: orderItem,
        callback: () => {
          this.refreshOrderList();
        },
      });
    }
  }

  public async searchOrder(value: string) {
    this.keywords = value;
    this.reachEnd = false;
    this.curPage = 1;
    this.totalNum = 0;
    this.currentIndex = 0;
    this.getOrderList(true, this.keywords);
  }
}
