import { RouterPageEnum, UserInfoStorage, AuthenticationUtil, UserInfo } from 'common';
import { GlobalDialog } from 'components'
import { PersistenceV2 } from '@kit.ArkUI';
import { MainEntryVM } from '../viewmodel/MainEntryVM';
import { TabInfo } from '../types';

@Entry
@ComponentV2
struct Index {
  vm: MainEntryVM = MainEntryVM.instance;
  @Local userInfoStorage: UserInfoStorage =
    PersistenceV2.connect(UserInfoStorage, 'UserInfoStorage', () => new UserInfoStorage())!
  @Local currentTabIndex: number = 0;
  private tabController: TabsController = new TabsController()

  aboutToAppear() {
    this.widgetInterception()
  }

  // 卡片跳转拦截
  widgetInterception() {
    let message = AppStorage.get('widgetRouter') ?? ''
    if (!message) {
      return
    }
    if (message === 'book_ticket') {
      this.tabController.changeIndex(0)
      this.currentTabIndex = 0
    } else if (message === 'my_trip') {
      this.tabController.changeIndex(1)
      this.currentTabIndex = 1
    } else if (message === 'search_flight') {
      this.tabController.changeIndex(2)
      this.currentTabIndex = 2
    } else if (message === 'my_order') {
      // 如果已登录
      if (this.userInfoStorage.isLogin) {
        this.tabController.changeIndex(3)
        this.currentTabIndex = 3
        this.vm.navStack.pushPathByName('OrderCenterPage', '')
      } else {
        GlobalDialog.showTextDialog({
          title: '关联账号',
          content: '请先关联账号',
          primaryButName: '确定',
          secondaryButName: '取消',
          primaryButAction: async () => {
            // 关闭账号关联弹框
            await GlobalDialog.close()
            // loading弹框
            await GlobalDialog.showLoadingDialog()
            AuthenticationUtil.silentLogin(async (isSuccess: boolean, userInfo: UserInfo) => {
              await GlobalDialog.close()
              // 账号关联登录成功
              if (isSuccess) {
                this.userInfoStorage.isLogin = true;
                this.userInfoStorage.userInfo = userInfo
                this.tabController.changeIndex(3)
                this.currentTabIndex = 3
                this.vm.navStack.pushPathByName('OrderCenterPage', '')
              }
            })
          },
          secondaryButAction: () => {
            GlobalDialog.close()
          },
        })
      }
    }
  }

  build() {
    Navigation(this.vm.navStack) {
      Tabs({
        barPosition: BarPosition.End,
        index: this.currentTabIndex,
        controller: this.tabController,
      }) {
        ForEach(this.vm.tabInfos, (item: TabInfo, index: number) => {
          TabContent() {
            item.component.builder()
          }
          .tabBar(this.TabItem(item, index))
          .backgroundColor(item.pageBgColor)
          .expandSafeArea([SafeAreaType.SYSTEM], item.safeAreaEdge)
        })
      }
      .barWidth('100%')
      .scrollable(false)
      .animationDuration(0)
      .backgroundColor($r('sys.color.white'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .onChange((index: number) => {
        this.currentTabIndex = index;
      });
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }

  @Builder
  TabItem(tab: TabInfo, index: number) {
    Column({ space: 3 }) {
      Image(this.currentTabIndex === index ? tab.activeIcon : tab.defaultIcon)
        .width(20);
      Text(tab.label)
        .fontSize(10)
        .lineHeight(14)
        .fontWeight(FontWeight.Regular)
        .fontColor(this.currentTabIndex === index ? $r('sys.color.ohos_id_color_emphasize') :
        $r('sys.color.ohos_id_color_text_primary'))
    }
  }
}
