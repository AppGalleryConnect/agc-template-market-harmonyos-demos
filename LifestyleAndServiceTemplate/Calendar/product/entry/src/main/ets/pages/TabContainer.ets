import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { baseToast, getDataFromJSON } from 'base_apis';
import { PerpetualCalendar } from 'perpetual'
import { TabsInfo, ThemeModel, UserState, WeekStart } from 'common'
import { Almanac } from 'almanac'
import { MinePage } from 'mine'
import { RouterModule } from 'router_module';
import { IndexVM } from '../viewmodel/IndexVM';
import { FormCardParams, FormCardRouter } from '../common/Types';


@ComponentV2
export struct TabContainer {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;
  @Local currentIndex: number = 0
  @Local tabsInfos: TabsInfo[] = []
  private controller: TabsController = new TabsController()
  @Local weekStart: WeekStart = PersistenceV2.connect(WeekStart, () => new WeekStart())!;
  @Local formCardModel: FormCardRouter = AppStorageV2.connect(FormCardRouter, () => new FormCardRouter())!;
  vm: IndexVM = new IndexVM();

  getTabsInfo() {
    this.tabsInfos = getDataFromJSON<TabsInfo>(this.getUIContext().getHostContext()!, 'Tabs_Info.json');
  }

  aboutToAppear() {
    this.getTabsInfo()
    this.registerInterception()
  }

  @Monitor('formCardModel.id')
  onFormCardClick() {
    this.widgetInterception();
  }

  /*
   * 卡片跳转拦截
   * */
  widgetInterception() {
    if (!this.formCardModel) {
      return
    }
    try {
      const message: FormCardParams = JSON.parse(this.formCardModel.params)
      if (!message.message) {
        return
      }
      if (message.message === 'almanac') {
        this.controller.changeIndex(1)
      } else {
        this.controller.changeIndex(0)
      }
    } catch (e) {
      UtilLog.error('form card error' + JSON.stringify(e))
    }
  }

  /*
   * 路由拦截
   * */
  registerInterception() {
    RouterModule.setInterception({
      // 页面跳转前拦截，允许操作栈，在当前跳转中生效。
      willShow: (from: NavDestinationContext | 'navBar', to: NavDestinationContext | 'navBar',
        operation: NavigationOperation, animated: boolean) => {
        if (typeof to === 'string') {
          return;
        }
        /*
         * 判断登录状态,并跳转到我的页面进行关联
         * */
        let target: NavDestinationContext = to as NavDestinationContext;
        if (!this.userState.isLogin &&
          ['PersonInformation', 'VipOpenCenter'].includes(target?.pathInfo?.name)) {
          baseToast.show(this.getUIContext(), {
            type: 'dialog',
            hasTitle: $r('app.string.associated_account'),
            message: $r('app.string.associated_account_tips'),
            confirmAction: () => {
              RouterModule.pushPathByName({ url: 'LoginWithHuaweiID' })
              baseToast.hide()
            },
          })
          target.pathStack.pop();
        }
      },
    })
  }

  @Builder
  tabBuilder(index: number, name: string) {
    Column({ space: 5 }) {
      Image(this.currentIndex === index ? $r(this.tabsInfos[index].icon) : $r(this.tabsInfos[index].iconSel))
        .width(24)
        .fillColor(this.currentIndex === index ? this.theme.themeState.tabColor :
          this.theme.themeState.tabColorInActive)
      Text(name)
        .fontColor(this.currentIndex === index ? this.theme.themeState.tabColor :
          this.theme.themeState.tabColorInActive)
        .fontSize($r('sys.float.Caption_M'))
    }
    .width('100%')
    .margin({ top: 5, bottom: Number(AppStorage.get('bottomRectHeight')) })
  }

  build() {
    Column() {
      Tabs({ index: this.currentIndex, controller: this.controller }) {
        TabContent() {
          PerpetualCalendar({
            jumpToAlmanac: () => {
              this.controller.changeIndex(1)
            },
          })
        }.tabBar(this.tabBuilder(0, '万年历'))

        TabContent() {
          Almanac()
        }.tabBar(this.tabBuilder(1, '黄历'))

        TabContent() {
          MinePage()
        }.tabBar(this.tabBuilder(2, '我的'))
      }
      .scrollable(false)
      .animationDuration(0)
      .animation({ duration: 200, curve: Curve.EaseInOut })
      .vertical(this.vm.isTabVertical)
      .barPosition(this.vm.barPosition)
      .barOverlap(!this.vm.isTabVertical)
      .barMode(this.vm.isTabVertical ? BarMode.Scrollable : BarMode.Fixed)
      .barHeight(this.vm.tabBarHeight)
      .barWidth(this.vm.tabWidth)
      .barBackgroundColor(this.theme.themeState.current)
      .barBackgroundBlurStyle(BlurStyle.NONE)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .onAreaChange(() => {
        this.widgetInterception()
      })
    }
    .width('100%')
    .height('100%')
  }
}