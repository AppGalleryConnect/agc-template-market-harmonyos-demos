import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  BusinessTimeDialog,
  CardManager,
  Constants,
  CouponResp,
  FormDataClass,
  GetTableInfoResp,
  getTableInfoUtil,
  GetUserInfoResp,
  HttpRequestApi,
  HuaweiIDResp,
  HwMap,
  Reduction,
  StoreInfo,
  StoreSet,
  StoreType,
  TableTitle,
} from 'common/Index';
import 'order/src/main/ets/pages/OrderPage';
import { OrderPage } from 'order/src/main/ets/pages/OrderPage';
import {
  ConfirmOrderPage,
  GoodDetailPage,
  MerchantDetailPage,
  PreviewImagePage,
  RemarksPage,
  SelectCouponPage,
} from 'order';
import { clearCarUtil, getCouponListUtil, getMyCarUtil, getStoreInfoUtil } from 'common/src/main/ets/utils/Utils';
import { HomePage } from './HomePage';
import { AnswerPage, FrequentQuestionPage, MyCouponsPage } from 'personal_center';
import { OrderDetailPage } from 'order_list';
import { MustGoodsController } from 'order/src/main/ets/models/MustGoodsController';
import dataPreferences from '@ohos.data.preferences';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @StorageProp('storeId') @Watch('initQuery') storeId: string = '';
  @StorageProp('storeType') storeType: number = 1;
  @StorageLink('userId') userId: string = '';
  @StorageLink('authCode') authCode: string = '';
  @StorageLink('tableId') tableId: string = '';
  @StorageLink('userTel') userTel: string = '';
  @StorageLink('userName') userName: string = '';
  @StorageLink('totalScore') totalScore: string = '';
  @StorageLink('wallet') wallet: string = '';
  @StorageProp('qrCodeFlag') qrCodeFlag: boolean = false;
  @StorageLink('isRest') isRest: boolean = false;
  @StorageProp('tableList') @Watch('initTableTitle') tableList: Array<TableTitle> = [];
  @Provide('storeInfo') storeInfo: StoreInfo = new StoreInfo();
  @Provide('storeSet') storeSet: StoreSet = new StoreSet();
  @Provide('reductionList') reductionList: Array<Reduction> = [];
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();
  @Provide('tableInfo') tableInfo?: GetTableInfoResp = undefined;
  @Provide('mustGoodsCtrl') mustGoodsCtrl: MustGoodsController = new MustGoodsController();
  @Provide('orderId') orderId?: string = undefined;
  @Provide('couponList') couponList?: Array<CouponResp> = [];
  @State openId: string = '';
  @State unionId: string = '';
  businessController: CustomDialogController = new CustomDialogController({
    builder: BusinessTimeDialog(),
    width: 296,
    height: 348,
  });

  aboutToAppear() {
    this.loginWithHuaweiID().then(res => {
      this.openId = res.openId;
      this.unionId = res.unionId;
      this.authCode = res.authCode;
      if (this.storeId) {
        this.initQuery();
      } else {
        console.info(`initQuery is from watch.`);
      }
    });
  }

  initQuery() {
    // 查询用户信息
    this.getUserInfo(this.openId, this.unionId).then((resp) => {
      this.userId = resp.id;
      this.wallet = resp.wallet;
      this.totalScore = resp.totalScore;
      this.userTel = resp.userTel ?? '';
      this.userName = resp.name;
      if (this.qrCodeFlag) {
        clearCarUtil();
      } else {
        getMyCarUtil().then((res) => {
          res.res?.forEach(item => {
            if (item.isMust === Constants.GOODS_MUST) {
              this.mustGoodsCtrl.addIsMust(Number(item.num));
            }
          });
        });
      }
      getCouponListUtil().then((resp: Array<CouponResp>) => {
        this.couponList = resp;
      });
    });
    this.initTableTitle();
    this.pageStack.replacePath({ name: 'HomePage' });
  }

  initTableTitle() {
    if (!this.tableList.length) {
      return;
    }
    getStoreInfoUtil(this.storeId).then(res => {
      this.storeInfo = res.store;
      AppStorage.setOrCreate('storeInfo', res.store);
      this.updateFormCard();
      this.storeSet = res.storeSet;
      this.reductionList = res.reduction;
      if (this.storeInfo.isRest === Constants.STORE_REST ||
        new Date().getTime() < this.getTimeByHour(this.storeInfo.time) ||
        new Date().getTime() > this.getTimeByHour(this.storeInfo.time4)) {
        if (!this.isRest) {
          this.businessController?.open();
        }
        this.isRest = true;
      } else {
        this.isRest = false;
      }
    });
    if (this.storeType === StoreType.SCAN_TYPE && this.tableId) {
      getTableInfoUtil(this.tableId).then((res) => {
        this.tableInfo = res;
      });
    }
  }

  updateFormCard() {
    dataPreferences.removePreferencesFromCacheSync(getContext(this), { name: CardManager.KEY_CARD_ID })
    let pref = dataPreferences.getPreferencesSync(getContext(this), { name: CardManager.KEY_CARD_INFO });
    let dataClass = new FormDataClass();
    dataClass.storeName = this.storeInfo.name || '';
    pref.putSync(CardManager.KEY_CARD_INFO, dataClass);
    pref.flush();
    CardManager.get().updateCard(getContext(this), '', dataClass);
  }

  getTimeByHour(time: string = '') {
    let date = new Date(`${new Date().toLocaleDateString()} ${time}`)
    return date.getTime()
  }

  @Builder
  PageMap(name: string) {
    if (name === 'HomePage') {
      HomePage();
    } else if (name === 'OrderPage') {
      OrderPage();
    } else if (name === 'MerchantDetailPage') {
      MerchantDetailPage();
    } else if (name === 'GoodDetailPage') {
      GoodDetailPage();
    } else if (name === 'ConfirmOrderPage') {
      ConfirmOrderPage();
    } else if (name === 'FrequentQuestionPage') {
      FrequentQuestionPage();
    } else if (name === 'OrderDetailPage') {
      OrderDetailPage();
    } else if (name === 'HwMap') {
      HwMap();
    } else if (name === 'AnswerPage') {
      AnswerPage();
    } else if (name === 'SelectCouponPage') {
      SelectCouponPage();
    } else if (name === 'MyCouponsPage') {
      MyCouponsPage();
    } else if (name === 'RemarksPage') {
      RemarksPage();
    } else if (name === 'PreviewImagePage') {
      PreviewImagePage();
    }
  }

  build() {
    Column() {
      Navigation(this.pageStack) {
      }
      .hideTitleBar(true)
      .hideNavBar(true)
      .navDestination(this.PageMap)
      .mode(NavigationMode.Stack)
      .height(Constants.FULL_SIZE)
      .width(Constants.FULL_SIZE);
    }
    .height(Constants.FULL_SIZE)
    .width(Constants.FULL_SIZE);

  }

  /**
   * Sample code for using HUAWEI ID to log in to atomic service.
   * According to the Atomic Service Review Guide, when a atomic service has an account system,
   * the option to log in with a HUAWEI ID must be provided.
   * The following presets the atomic service to use the HUAWEI ID silent login function.
   * To enable the atomic service to log in successfully using the HUAWEI ID, please refer
   * to the HarmonyOS HUAWEI ID Access Guide to configure the client ID and fingerprint certificate.
   */
  private loginWithHuaweiID(): Promise<HuaweiIDResp> {
    return new Promise((resolve, reject) => {
      // Create a login request and set parameters
      let loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
      // Whether to forcibly launch the HUAWEI ID login page when the user is not logged in with the HUAWEI ID
      loginRequest.forceLogin = false;
      // Execute login request
      let controller = new authentication.AuthenticationController();
      controller.executeRequest(loginRequest).then((data) => {
        let loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
        let authCode = loginWithHuaweiIDResponse.data?.authorizationCode;
        let openId = loginWithHuaweiIDResponse.data?.openID;
        let unionId = loginWithHuaweiIDResponse.data?.unionID;
        resolve({ openId, unionId, authCode } as HuaweiIDResp);
        // Send authCode to the backend in exchange for unionID, session

      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'testTag', 'error: %{public}s', JSON.stringify(error));
        if (error.code === authentication.AuthenticationErrorCode.ACCOUNT_NOT_LOGGED_IN) {
          // HUAWEI ID is not logged in, it is recommended to jump to the login guide page
          promptAction.showToast({ message: $r('app.string.login_account') })
        }
        reject(error);
      });
    });

  }

  private getUserInfo(openid: string, unionId: string): Promise<GetUserInfoResp> {
    return new Promise((resolve, reject) => {
      HttpRequestApi.getUserInfo(this.storeId, openid, unionId)
        .then((resp: GetUserInfoResp) => {
          if (resp.id) {
            console.info(`getUserInfo resp:${JSON.stringify(resp)}.`);
            resolve(resp);
          } else {
            console.error(`getUserInfo error: ${JSON.stringify(resp)}.`);
            reject(resp.msg);
          }
        })
        .catch((e: BusinessError) => {
          console.error(`getUserInfo error: ${JSON.stringify(e)}.`);
          reject(e);
        });
    });
  }
}
