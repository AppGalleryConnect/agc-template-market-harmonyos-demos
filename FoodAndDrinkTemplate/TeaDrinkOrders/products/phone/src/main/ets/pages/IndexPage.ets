import { CustomTabBar } from '../components/CustomTabBar';
import { Constants, FormCard, IndexPageRouter, OrderDetailRouter, RouterMap, StoreInfoModel } from 'common';
import { HomePageBuilder } from 'home';
import { OrderPageBuilder } from 'order';
import { OrderListPageBuilder } from 'order_list';
import { TabBarType } from 'common/src/main/ets/models/TabBarModel';
import { MinePageBuilder } from 'mine';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function IndexPageBuilder() {
  IndexPage()
}

@ComponentV2
struct IndexPage {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack();
  @Provider('currentIndex') currentIndex: TabBarType = TabBarType.HOME_PAGE;
  @Local storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local formCard: FormCard = AppStorageV2.connect(FormCard, () => new FormCard())!

  aboutToAppear(): void {
    this.getParams();
  }

  @Monitor('formCard.id')
  formCardChange(monitor: IMonitor) {
    if (monitor.value()?.now) {
      let currentName: string[] = this.pageStack.getAllPathName()
      if (this.formCard.url && currentName.length &&
        currentName[currentName.length-1] === RouterMap.ORDER_DETAIL_PAGE) {
        this.pageStack.replacePathByName(this.formCard.url, { orderId: this.formCard.orderId } as OrderDetailRouter);
      } else {
        this.pageStack.pushPathByName(this.formCard.url, { orderId: this.formCard.orderId } as OrderDetailRouter);
      }
      this.formCard.url = '';
    }
  }

  getParams() {
    let paramsArr: IndexPageRouter[] = this.pageStack.getParamByName(RouterMap.INDEX_PAGE) as IndexPageRouter[];
    if (paramsArr.length) {
      let routerParam = paramsArr[paramsArr.length-1];
      this.currentIndex = routerParam?.index ?? TabBarType.HOME_PAGE;
      this.storeInfo.storeId = routerParam?.storeId ?? '';
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Flex({
          direction: FlexDirection.Column,
        }) {
          Tabs({ index: this.currentIndex }) {
            TabContent() {
              wrapBuilder(HomePageBuilder).builder()
            };

            TabContent() {
              wrapBuilder(OrderPageBuilder).builder()
            };

            TabContent() {
              wrapBuilder(OrderListPageBuilder).builder()
            };

            TabContent() {
              wrapBuilder(MinePageBuilder).builder()
            };
          }
          .layoutWeight(1)
          .barHeight(0)
          .scrollable(false)
          .onChange((index) => {
            this.currentIndex = index;
          });

          CustomTabBar();
        }
        .width(Constants.FULL_SIZE)
        .height(Constants.FULL_SIZE);
      };
    }.hideTitleBar(true).onShown(() => {
      // 返回到点单页如果未选择店铺，则回到首页
      if (this.currentIndex === TabBarType.ORDER && !this.storeInfo.storeId) {
        this.currentIndex = TabBarType.HOME_PAGE
      }
    })
  }
}