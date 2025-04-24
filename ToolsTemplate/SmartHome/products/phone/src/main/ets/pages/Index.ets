import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { HomePage } from './HomePage';
import { MinePage } from './MinePage';
import { uiObserver } from '@kit.ArkUI';
import { ProductPage } from './ProductPage';
import { AccessControlViewModel } from '../viewmodel/AccessControlViewModel';
;

interface TabInfo {
  pathStack: NavPathStack;
  title: string;
  targetIndex: number;
  selectedImg: Resource;
  normalImg: Resource;
}

@Entry
@ComponentV2
struct Index {
  @Local isTabBarVisible: boolean = true;
  pagesTabInfo: TabInfo[] = [
    {
      pathStack: new NavPathStack(),
      title: '首页',
      targetIndex: 0,
      selectedImg: $r('app.media.house_filled'),
      normalImg: $r('app.media.house'),
    },
    {
      pathStack: new NavPathStack(),
      title: '产品',
      targetIndex: 1,
      selectedImg: $r('app.media.product_filled'),
      normalImg: $r('app.media.product'),
    },
    {
      pathStack: new NavPathStack(),
      title: '我的',
      targetIndex: 2,
      selectedImg: $r('app.media.mine_filled'),
      normalImg: $r('app.media.mine'),
    },
  ];
  @Local currentIndex: number = this.pagesTabInfo[0].targetIndex;
  private controller: TabsController = new TabsController();

  getCurrentPathStack(): NavPathStack {
    let currentPathStack = this.pagesTabInfo[0].pathStack;
    this.pagesTabInfo.forEach((item => {
      if (item.targetIndex === this.currentIndex) {
        currentPathStack = item.pathStack;
      }
    }));
    return currentPathStack;
  }

  clearPathStack() {
    this.pagesTabInfo.forEach((item => {
      item.pathStack.clear();
    }));
  }

  onPageShow(): void {
    this.pushDestinationPath();
    this.getAccess();
  }

  @Builder
  tabBuilder(tabInfo: TabInfo) {
    Column() {
      Image(this.currentIndex === tabInfo.targetIndex ? tabInfo.selectedImg : tabInfo.normalImg)
        .size({ width: 26, height: 26 })
        .margin({ top: 12 });
      Text(tabInfo.title)
        .fontColor(this.currentIndex === tabInfo.targetIndex ? '#0A59F7' : '#000000')
        .fontSize(11)
        .fontWeight(FontWeight.Medium)
        .opacity(this.currentIndex === tabInfo.targetIndex ? 1 : 0.6);
    }
    .justifyContent(FlexAlign.Center);
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex, controller: this.controller }) {
      TabContent() {
        HomePage({ pathStack: this.pagesTabInfo[0].pathStack });
      }
      .expandSafeArea([SafeAreaType.SYSTEM])
      .tabBar(this.tabBuilder(this.pagesTabInfo[0]));

      TabContent() {
        ProductPage({ pathStack: this.pagesTabInfo[1].pathStack });
      }
      .expandSafeArea([SafeAreaType.SYSTEM])
      .tabBar(this.tabBuilder(this.pagesTabInfo[1]));

      TabContent() {
        MinePage({ pathStack: this.pagesTabInfo[2].pathStack });
      }
      .expandSafeArea([SafeAreaType.SYSTEM])
      .tabBar(this.tabBuilder(this.pagesTabInfo[2]));
    }
    .backgroundColor('#F9FAFB')
    .expandSafeArea([SafeAreaType.SYSTEM])
    .scrollable(false)
    .barHeight(this.isTabBarVisible ? 60 : 0)
    .onChange((index: number) => {
      this.currentIndex = index;
    });

  }

  aboutToAppear() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    this.loginWithHuaweiID();


    uiObserver.on('navDestinationUpdate', (info: NavDestinationInfo) => {
      let sum = 0;
      this.pagesTabInfo.forEach((item) => {
        sum += item.pathStack.size();
      });
      this.isTabBarVisible = (sum === 0);
    });
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  private pushDestinationPath() {
    let targetDeviceId = AppStorage.get('targetDeviceId') as string;
    if (targetDeviceId !== '' && targetDeviceId !== undefined) {
      let currentPathStack = this.getCurrentPathStack();
      this.delay(400).then(() => {
        currentPathStack.pushPathByName('DeviceDetailPage', targetDeviceId);
      });
    }
    AppStorage.setOrCreate('targetDeviceId', '');
  }

  private async getAccess() {
    AccessControlViewModel.getInstance().getAccess();
  }

  /**
   * Sample code for using HUAWEI ID to log in to atomic service.
   * According to the Atomic Service Review Guide, when a atomic service has an account system,
   * the option to log in with a HUAWEI ID must be provided.
   * The following presets the atomic service to use the HUAWEI ID silent login function.
   * To enable the atomic service to log in successfully using the HUAWEI ID, please refer
   * to the HarmonyOS HUAWEI ID Access Guide to configure the client ID and fingerprint certificate.
   */
  private loginWithHuaweiID() {
    // Create a login request and set parameters
    let loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    // Whether to forcibly launch the HUAWEI ID login page when the user is not logged in with the HUAWEI ID
    loginRequest.forceLogin = false;
    // Execute login request
    let controller = new authentication.AuthenticationController();
    controller.executeRequest(loginRequest).then((data) => {
      let loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
      let authCode = loginWithHuaweiIDResponse.data?.authorizationCode;
      // Send authCode to the backend in exchange for unionID, session

    }).catch((error: BusinessError) => {
      hilog.error(0x0000, 'testTag', 'error: %{public}s', JSON.stringify(error));
      if (error.code === authentication.AuthenticationErrorCode.ACCOUNT_NOT_LOGGED_IN) {
        // HUAWEI ID is not logged in, it is recommended to jump to the login guide page

      }
    });
  }
}
