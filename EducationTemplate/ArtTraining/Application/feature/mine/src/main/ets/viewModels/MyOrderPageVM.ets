import { FrameworkUtil, OrderInfo, OrderTabsMap, RouterMap, RouterModule, TabsIndexMap } from 'commonlib';
import { https } from 'network';
import { ORDER_TAB_LIST } from '../constants/Constants';
import { OrderActionMap } from '../constants/Enums';
import { OrderUtil } from '../utils/OrderUtil';

@ObservedV2
export class MyOrderPageVM {
  // 首页数据模型
  @Trace orderList: OrderInfo[] = [];
  @Trace isLoading: boolean = false;
  @Trace currentIndex: number = 0;
  tabController: TabsController = new TabsController();
  private static _instance: MyOrderPageVM;

  public static get instance() {
    if (!MyOrderPageVM._instance) {
      MyOrderPageVM._instance = new MyOrderPageVM();
    }
    return MyOrderPageVM._instance;
  }

  public initOrderList() {
    const param = RouterModule.getNavParam<number>({
      url: RouterMap.MINE_ORDER_LIST,
    });
    if (typeof param === 'number') {
      this.tabController.changeIndex(param);
      this.getOrderList(param);
    }
  }

  public async getOrderList(index: OrderTabsMap) {
    this.currentIndex = index;
    this.isLoading = true;
    this.orderList = [];
    const orderStatus = ORDER_TAB_LIST[this.currentIndex].status;
    const res = await https.getOrderList({
      fromPage: 1,
      pageSize: 100,
      orderStatus,
    });
    if (res.ret.code === 0) {
      this.orderList = res.result.orderList;
    }
    this.isLoading = false;
  }

  public handleOrderOperation(item: OrderInfo, buttonType: OrderActionMap) {
    OrderUtil.handleOrderOperation(item, buttonType, () => {
      this.getOrderList(this.currentIndex);
    });
  }

  public jumpToOrderDetail(order: OrderInfo) {
    RouterModule.push({
      url: RouterMap.MINE_ORDER_DETAIL,
      param: order.orderNo,
    });
  }

  public jumpToCourseCenter() {
    FrameworkUtil.switchTab(TabsIndexMap.COURSES_LIST);
    RouterModule.clear();
  }
}