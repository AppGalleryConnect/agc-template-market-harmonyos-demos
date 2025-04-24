import { https, OrderItem } from 'network';
import { AccountUtil, FormatUtil } from 'commonlib';
import { OrderClass, TabItem } from '../types';

@ObservedV2
export class MyOrderPageVM {
  // 首页数据模型
  @Trace orderList: OrderItem[] = [];
  @Trace isLoading: boolean = false;
  @Trace currentIndex: number = 0;
  @Trace userId: number = 0;
  public tabList: TabItem[] = [
    {
      label: '全部',
      class: OrderClass.ALL,
    },
    {
      label: '待付款',
      class: OrderClass.PENDING_PAYMENT,
    },
    {
      label: '待使用',
      class: OrderClass.PENDING_USAGE,
    },
    {
      label: '已完成',
      class: OrderClass.COMPLETE,
    },
    {
      label: '已取消',
      class: OrderClass.CANCEL,
    },
  ];
  private static _instance: MyOrderPageVM;

  public static get instance() {
    if (!MyOrderPageVM._instance) {
      MyOrderPageVM._instance = new MyOrderPageVM();
    }
    return MyOrderPageVM._instance;
  }

  // 初始化数据
  public initData() {
    this.getUserId();
    this.getOrderList();
  }

  private getUserId() {
    let userInfo = AccountUtil.getUserInfo();
    this.userId = userInfo.id;
  }

  public async getOrderList() {
    this.isLoading = true;
    this.orderList = [];
    const orderClass = this.tabList[this.currentIndex].class;
    const res = await https.getOrderList(this.userId, orderClass);
    if (res.code === 0) {
      const initOrderList = res.data;
      initOrderList.sort((a, b) => {
        return new Date(b.createTime).getTime() - new Date(a.createTime).getTime();
      });
      initOrderList.forEach((initItem) => {
        const item = this.getOrderItem(initItem);
        if (item.orderStatus === '' + orderClass || orderClass === OrderClass.ALL) {
          this.orderList.push(item);
        }
      });
    }
    this.isLoading = false;
  }

  private getOrderItem(initItem: OrderItem) {
    const item: OrderItem = JSON.parse(JSON.stringify(initItem));
    item.shopLogo = FormatUtil.getImgResource((item.shopLogo ?? '') as string);
    item.displayImg = FormatUtil.getImgResource((item.displayImg ?? '') as string);
    return item;
  }
}
