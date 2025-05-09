import { HomePage, ServiceManage, ServiceSearch } from 'home';
import { Login, LoginWithHuaweiIDComponent, Message, MinePage, Settings } from 'mine';
import { InteractionPage } from 'interaction';
import { OfficePage, SiteList } from 'office';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { CustomTabBar } from './components/CustomTabBar';
import { H5 } from 'h5';
import { CloudFunction, ParamsObj } from 'common';
import {
  AboutUs,
  CodeMockPage,
  FeedbackList,
  NodataPage,
  PersonInformation,
  PrivacyPolicyPage,
  ScanCodeResult,
  SuggestionPage,
  TermsOfServicePage,
} from 'components';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';

PersistentStorage.persistProp('isLogin', '')
PersistentStorage.persistProp('userInfo', '')
PersistentStorage.persistProp('suggestionList', [])
PersistentStorage.persistProp('isAllowPush', true)

@Entry
@Component
struct MainPage {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();
  @State tabCurrentIndex: number = 0
  @StorageLink('isLogin') isLogin: boolean = AppStorage.get('isLogin') ?? false;
  private firstBackTimestamp: number = 0;

  /*
   * 路由拦截
   * */
  registerInterception() {
    this.pageInfos.setInterception({
      // 页面跳转前拦截，允许操作栈，在当前跳转中生效。
      willShow: (from: NavDestinationContext | 'navBar', to: NavDestinationContext | 'navBar',
        operation: NavigationOperation, animated: boolean) => {
        if (typeof to === 'string') {
          console.log('target page is navigation home');
          return;
        }
        /*
         * 判断登录状态,并跳转到我的页面进行关联
         * */
        let target: NavDestinationContext = to as NavDestinationContext;
        if (!this.isLogin && !['PrivacyPolicyPage', 'Login', 'TermsOfServicePage'].includes(target.pathInfo.name)) {
          target.pathStack.pop();
          this.pageInfos.pushPathByName('LoginWithHuaweiIDComponent', null)
        }
      },
    })
  }

  getNoticePermission() {
    let requestEnableNotificationCallback = (err: BusinessError): void => {
      if (err) {
        console.error(`requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
      } else {
        //   推送消息
        if (!AppStorage.get('isAllowPush')) {
          return
        }
        CloudFunction.pushMessage(AppStorage.get('pushToken') ?? '')
      }
    };
    notificationManager.requestEnableNotification(getContext(this) as common.UIAbilityContext,
      requestEnableNotificationCallback);
  }

  aboutToAppear(): void {
    this.getNoticePermission()
    this.registerInterception()
  }

  onBackPress() {
    let now = Date.now();
    if (now - this.firstBackTimestamp < 1000) {
      const context = getContext(this) as common.UIAbilityContext
      context.terminateSelf();
    } else {
      this.firstBackTimestamp = now;
      let option: promptAction.ShowToastOptions = {
        message: $r('app.string.press_once'),
      }
      promptAction.showToast(option);
    }
    return true
  }

  @Builder
  PageMap(name: string, params: ParamsObj) {
    if (name === 'SearchPage') {
      ServiceSearch()
    } else if (name === 'SiteList') {
      SiteList()
    } else if (name === 'LoginWithHuaweiIDComponent') {
      LoginWithHuaweiIDComponent()
    } else if (name === 'Message') {
      Message()
    } else if (name === 'Login') {
      Login()
    } else if (name === 'ServiceManage') {
      ServiceManage()
    } else if (name === 'H5') {
      H5({
        title: params.title,
        loadUrl: params.loadUrl,
      })
    } else if (name === 'Settings') {
      Settings()
    } else if (name === 'Empty') {
      NodataPage({
        title: params.title,
      })
    } else if (name === 'CodeMock') {
      CodeMockPage({
        title: params.title,
      })
    } else if (name === 'Suggestion') {
      SuggestionPage()
    } else if (name === 'Feedback') {
      FeedbackList()
    } else if (name === 'AboutUs') {
      AboutUs()
    } else if (name === 'PersonInformation') {
      PersonInformation()
    } else if (name === 'PrivacyPolicyPage') {
      PrivacyPolicyPage()
    } else if (name === 'TermsOfServicePage') {
      TermsOfServicePage()
    } else if (name === 'ScanCodeResult') {
      ScanCodeResult({
        scanResult: params.title ,
      })
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Stack() {
        Flex({ direction: FlexDirection.Column }) {
          Tabs({ index: this.tabCurrentIndex, barPosition: BarPosition.End, controller: this.tabsController }) {
            TabContent() {
              HomePage()
            }

            TabContent() {
              OfficePage()
            }

            TabContent() {
              InteractionPage()
            }

            TabContent() {
              MinePage()
            }
          }
          .vertical(false)
          .divider({
            strokeWidth: 0.5,
            color: '#0D182431',
          })
          .barHeight(0)
          .scrollable(false)
          .layoutWeight(1)
          .animationDuration(0) //去掉切换页面的动画
          CustomTabBar({
            currentIndex: this.tabCurrentIndex,
          })
        }
      }.width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.PageMap)
  }
}