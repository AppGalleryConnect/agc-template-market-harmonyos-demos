import { OrderItem } from './MyOrderPageVM';

@ObservedV2
export class MyOrderSearchPageVM {
  private static _instance: MyOrderSearchPageVM;

  public static get instance() {
    if (!MyOrderSearchPageVM._instance) {
      MyOrderSearchPageVM._instance = new MyOrderSearchPageVM();
    }
    return MyOrderSearchPageVM._instance;
  }

  @Trace searchCondition: string = '';
  @Trace searchResult: OrderInfoManager = new OrderInfoManager('', []);
  @Trace isShowResult: boolean = false;
  // 搜索历史
  @Trace historySearch: Array<string> = [];

  updateHistorySearch(content: string) {
    let index: number = this.historySearch.indexOf(content);
    if (index === -1) {
      this.historySearch.unshift(content);
      return;
    }
    this.historySearch.splice(index, 1);
    this.historySearch.unshift(content);
    return;
  }

  // 可关闭的删除弹窗id
  deleteDialogId: number = -1;

}

/**
 * 搜索页手机数码类
 */
export class PhoneMediaType {
  // 手机名称
  name: string = '';
  // 手机图片
  image: ResourceStr = '';

  constructor(name: string, image: ResourceStr) {
    this.name = name;
    this.image = image;
  }
}

/**
 * 订单搜索结果
 */
export class OrderInfoManager {
  // 订单名称关键词
  name: string = '';
  // 检索后订单列表
  list: Array<OrderItem> = [];

  constructor(name: string, list: Array<OrderItem>) {
    this.name = name;
    this.list = list;
  }
}