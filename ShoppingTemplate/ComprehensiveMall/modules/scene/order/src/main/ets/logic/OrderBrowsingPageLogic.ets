import { TabSwiperViewData } from '@components/tabswiper';
import { ComponentEntry } from '@common/customtypes';
import { buildOrderTab, OrderTabLogic } from '@guis/tabs';

import HashMap from '@ohos.util.HashMap';

import { buildOrderListPage } from '../pages/OrderListPage';
import { OrderListPageLogic } from './OrderListPageLogic';

@ObservedV2
export class OrderBrowsingPageLogic {

  @Trace
  public tabSwiperViewData: TabSwiperViewData = [];

  @Trace
  public initialIndex: number = 0;

  private tabLogicMap: HashMap<string, OrderTabLogic> = new HashMap();

  private contentLogicMap: HashMap<string, OrderListPageLogic> = new HashMap();

  private tabActiveId: string = '';

  public initTabSwiper(): void {
    const data: string[] = ['全部', '待付款', '待发货', '待收货', '退款/售后'];
    for (let i: number = 0; i < data.length; i++) {
      const item: string = data[i];
      this.registerTabLogic(item);
      this.registerContentLogic(item, i);
      if (i === this.initialIndex) {
        this.tabActiveId = data[i];
      }
      this.pushTabSwiperViewData(item);
    }
    if (this.tabActiveId !== '') {
      this.onTabSwiperChange(this.initialIndex, this.tabActiveId);
    }
  }

  private registerTabLogic(item: string): void {
    const tabLogic: OrderTabLogic = new OrderTabLogic();
    tabLogic.setLabel(item);
    this.tabLogicMap.set(item, tabLogic);
  }

  private registerContentLogic(item: string, type: number): void {
    const contentLogic: OrderListPageLogic = new OrderListPageLogic();
    contentLogic.type = type;
    this.contentLogicMap.set(item, contentLogic);
  }

  private pushTabSwiperViewData(item: string): void {
    const tabLogic: OrderTabLogic = this.tabLogicMap.get(item);
    const contentLogic: OrderListPageLogic = this.contentLogicMap.get(item);
    if (tabLogic) {
      this.tabSwiperViewData.push({
        id: item,
        tab: new ComponentEntry(wrapBuilder(buildOrderTab), [tabLogic]),
        tabContent: new ComponentEntry(wrapBuilder(buildOrderListPage), [contentLogic])
      });
    }
  }

  public onTabSwiperChange = (_: number, id: string): void => {
    this.tabLogicMap.get(this.tabActiveId)?.setSelected(false);
    this.tabActiveId = id;
    this.tabLogicMap.get(this.tabActiveId).setSelected(true);
    this.contentLogicMap.get(this.tabActiveId).refresh();
  }

}
