import {
  BaseStyleData,
  BrightnessUtil,
  commonToast,
  Constants,
  getQuickLoginAnonymousPhone,
  HomeServiceEnum,
  NavigationParams,
  ParamsObj,
  SuggestionList,
  UserInfo,
  UserState,
  WebCommon,
} from 'common';
import { Home } from 'home';
import { MinePage } from 'mine';
import { CustomTabBar } from './components/CustomTabBar';
import { InformationPage } from 'information';
import { ServicePage } from 'service';
import {
  AboutUsPage,
  CertificationProgress,
  DrugInquiry,
  FeedbackList,
  InstitutionsPage,
  MedicalCode,
  NodataPage,
  OlderModel,
  OnlineReservation,
  PersonInformation,
  ReservationRecordList,
  ServiceSearch,
  SuggestionPage,
} from 'components';
import { PersistenceV2 } from '@kit.ArkUI';

@Entry
@ComponentV2
struct Index {
  @Provider('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @Provider('tabCurrentIndex') tabCurrentIndex: number = 0
  @Provider('baseStyleData') baseStyleData: BaseStyleData = new BaseStyleData()
  tabController: TabsController = new TabsController()
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;
  @Local suggestionList: SuggestionList = PersistenceV2.connect(SuggestionList, () => new SuggestionList())!;

  interceptCodeChange(code: number) {
    if (code === HomeServiceEnum.Code && !this.userState.isLogin) {
      commonToast.show({
        type: 'dialog',
        hasTitle: '关联账号',
        message: $r('app.string.associated_account'),
        confirmAction: () => {
          getQuickLoginAnonymousPhone(getContext(this), (isLogin: boolean, userInfo: UserInfo) => {
            this.userState.isLogin = isLogin
            this.userState.userInfo = userInfo
          })
        },
      })
      return
    }
    this.tabCurrentIndex = code
  }

  /*
   * 卡片跳转拦截
   * */
  widgetInterception() {
    let message = AppStorage.get('widget_router') ?? ''
    if (!message) {
      return
    }
    if (message === 'qr_code') {
      this.interceptCodeChange(HomeServiceEnum.Code)
    } else if (message === 'insurance_information') {
      this.pageInfos.replacePathByName('web', new NavigationParams('参保信息', 'person.html'))
    } else if (message === 'consumption_record') {
      this.pageInfos.replacePathByName('web', new NavigationParams('消费记录', 'visit.html'))
    } else if (message === 'more') {
      this.tabCurrentIndex = HomeServiceEnum.Service
    } else {
      this.pageInfos.replacePathByName('business', new NavigationParams('定点医院', null, null, true))
    }
  }

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
        if (!this.userState.isLogin && !(target.pathInfo.param as ParamsObj)?.interception) {
          commonToast.show({
            type: 'dialog',
            hasTitle: '关联账号',
            message: $r('app.string.associated_account'),
            confirmAction: () => {
              getQuickLoginAnonymousPhone(getContext(this), (isLogin: boolean, userInfo: UserInfo) => {
                this.userState.isLogin = isLogin
                this.userState.userInfo = userInfo
              })
            },
          })
          target.pathStack.pop();
        }
      },
    })
  }

  @Builder
  PageMap(name: string, params: ParamsObj) {
    if (name === 'business') {
      InstitutionsPage({ title: params.title, isHospital: params.isHospital })
    } else if (name === 'web') {
      WebCommon({
        title: params.title,
        loadUrl: params.loadUrl,
      })
    } else if (name === 'reservation') {
      OnlineReservation({ title: params.title })
    } else if (name === 'record') {
      ReservationRecordList()
    } else if (name === 'medicines') {
      DrugInquiry({ title: params.title })
    } else if (name === 'progress') {
      CertificationProgress({ title: params.title })
    } else if (name === 'setting') {
      PersonInformation({ title: params.title })
    } else if (name === 'older') {
      OlderModel({ title: params.title })
    } else if (name === 'medicalCode') {
      MedicalCode()
    } else if (name === 'notAvailable') {
      NodataPage({ title: params.title })
    } else if (name === 'aboutUs') {
      AboutUsPage()
    } else if (name === 'suggestion') {
      SuggestionPage()
    } else if (name === 'serviceSearch') {
      ServiceSearch()
    } else if (name === 'feedback') {
      FeedbackList()
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Stack() {
        Flex({ direction: FlexDirection.Column }) {
          Tabs({
            barPosition: BarPosition.End, //底部导航
            index: this.tabCurrentIndex,
            controller: this.tabController,
          }) {
            TabContent() {
              Home({
                currentIndexChange: (value: number) => {
                  this.tabCurrentIndex = value
                },
              })
            }

            TabContent() {
              ServicePage()
            }

            TabContent() {
              MedicalCode()
            }

            TabContent() {
              InformationPage()
            }

            TabContent() {
              MinePage()
            }
          }
          .animationDuration(0) //去掉切换页面的动画
          .scrollable(false) //去掉左右滑动的效果
          .barHeight(0)
          .layoutWeight(1)
          .scrollable(false)
          .onChange((index: number) => {
            if (index !== HomeServiceEnum.Code) {
              BrightnessUtil.setBrightness(Constants.SET_BRIGHTNESS_CLICK)
            }
          })

          CustomTabBar({
            tabIndexChange: (index: number) => {
              this.interceptCodeChange(index)
            },
            currentIndex: this.tabCurrentIndex,
          })
        }
      }.width(Constants.FULL_PERCENT_WIDTH)
      .height(Constants.FULL_PERCENT_HEIGHT)
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.PageMap)
  }

  aboutToAppear() {
    this.widgetInterception()
    this.registerInterception()
  }

  onPageShow(): void {
    /*
     * 拦截未登录状态下，卡片路由进来会导致弹窗多实例
     * */
    commonToast.hide()
    this.widgetInterception()
  }
}