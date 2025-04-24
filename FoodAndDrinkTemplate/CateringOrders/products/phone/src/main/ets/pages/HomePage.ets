import { CustomTabBar } from '../components/CustomTabBar';
import { OrderPage } from 'order';
import { OrderListPage } from 'order_list';
import { PersonalCenterPage } from 'personal_center';
import { Constants, FormCardJump, HomePageRouter, TabBarType } from 'common';

@Component
export struct HomePage {
  @StorageProp('formCardJump') @Watch('formCardChange') formCardJump?: FormCardJump = undefined;
  @Consume('pageStack') pageStack: NavPathStack;
  @Provide('currentIndex') currentIndex: number = 0;
  @Provide('refreshData') refreshData: boolean = false;
  @Provide('showShopDiscount') showShopDiscount: boolean = false
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;

  aboutToAppear(): void {
    this.getParams();
  }

  formCardChange() {
    if (this.formCardJump?.url) {
      let currentName: string[] = this.pageStack.getAllPathName()
      if (currentName.length && currentName[currentName.length-1] === 'OrderDetailPage') {
        this.pageStack.replacePath({ name: this.formCardJump.url, param: this.formCardJump.params });
      } else {
        this.pageStack.pushPath({ name: this.formCardJump.url, param: this.formCardJump.params });
      }
      AppStorage.delete('formCardJump');
    }
  }

  getParams() {
    let paramsArr: HomePageRouter[] = this.pageStack.getParamByName('HomePage') as HomePageRouter[];
    if (paramsArr.length) {
      let routerParam = paramsArr[paramsArr.length-1];
      this.currentIndex = routerParam?.index ?? 0;
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
              OrderPage();
            };

            TabContent() {
              OrderListPage();
            };

            TabContent() {
              PersonalCenterPage();
            };
          }
          .layoutWeight(1)
          .barHeight(0)
          .scrollable(false)
          .onChange((index) => {
            this.currentIndex = index;
          });

          CustomTabBar({ currentIndex: $currentIndex });
        }
        .width(Constants.FULL_SIZE)
        .height(Constants.FULL_SIZE);
      };
    }.hideTitleBar(true).padding({ bottom: this.windowBottomHeight }).onBackPressed(() => {
      if (this.showShopDiscount) {
        this.showShopDiscount = false
        return true
      }
      return false
    })
    .onShown(() => {
      if (this.currentIndex === TabBarType.ORDER) {
        this.refreshData = true
      }
    })

  }
}