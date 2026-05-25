import { iap } from '@kit.IAPKit';
import { common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { BusinessError } from '@kit.BasicServicesKit';
import { display, LevelMode, window } from '@kit.ArkUI';
import {
  LoginApiController,
  MemberList,
  MemberParams,
  ProductInfo,
  PurchaseOrderPayload,
  UserStatus,
} from '../model/Index';
import { FinishStatus } from '../constant/Enum';
import { MemberStatusUtil } from '../util/MemberStatusUtil';

@ObservedV2
export class MemberShipVM {
  private static _instance: MemberShipVM;
  @Trace foldStatus: display.FoldStatus = display.FoldStatus.FOLD_STATUS_UNKNOWN;
  @Trace rotation: number = 0;
  @Trace isRenewMember: boolean = false;
  @Trace expiresTime: number = 0;
  @Trace groupId: string = '';
  @Trace memberParams: MemberParams = new MemberParams();
  @Trace renewProductId: string = '';
  @Trace autoRenewProductId: string = '';
  @Trace nonRenewProductId: string = '';
  @Trace loading: boolean = false;
  @Trace isShow: boolean = false;
  @Trace isMember: boolean = false;
  @Trace autoRenewPurchasedList: string[] = [];
  @Trace nonAutoRenewPurchasedList: string[] = [];
  @Trace productInfoList: iap.Product[] = [];
  @Trace selectedProductIndex: number = 0;
  @Trace isMemberPrivacyChecked: boolean = false;
  @Trace pathStack: NavPathStack = new NavPathStack();
  @Trace userStatus: UserStatus = new UserStatus();
  @Trace lastPurchaseProductExpireTime: string = '';
  subscribeCallBack: (params: MemberParams) => Promise<void> = () => new Promise(() => {
  });
  queryExpireTime: (productId: string, time?: number) => Promise<string> = () => new Promise(() => {
  });
  ownedMemberCallBack: (list: MemberList) => Promise<void> = () => new Promise(() => {
  });
  loginApiController: LoginApiController = new LoginApiController(() => new UserStatus(), () => {
  });
  @Trace uiContext?: UIContext;

  public static get instance() {
    if (!MemberShipVM._instance) {
      MemberShipVM._instance = new MemberShipVM();
    }
    return MemberShipVM._instance;
  }

  setEvent(subscribeCallBack: (params: MemberParams) => Promise<void>,
    queryExpireTime: (productId: string, time?: number) => Promise<string>,
    ownedMemberCallBack: (list: MemberList) => Promise<void>, loginApiController: LoginApiController) {
    this.queryExpireTime = queryExpireTime;
    this.subscribeCallBack = subscribeCallBack;
    this.ownedMemberCallBack = ownedMemberCallBack;
    this.loginApiController = loginApiController;
  }

  buyProduct(id: string, type: iap.ProductType, name: string) {
    this.memberParams.productId = id;
    this.memberParams.type = type;
    this.memberParams.name = name;
    try {
      const createPurchaseParam: iap.PurchaseParameter = {
        productId: id,
        productType: type,
      };
      iap.createPurchase(this.uiContext?.getHostContext() as common.UIAbilityContext, createPurchaseParam)
        .then((result) => {
          this.loading = true;
          if (Number(type) === iap?.ProductType.AUTORENEWABLE) {
            this.dealSubscribeData(result.purchaseData);
          } else if (Number(type) === iap?.ProductType.NONRENEWABLE ||
            Number(type) === iap?.ProductType.NONCONSUMABLE) {
            this.dealPurchaseData(result.purchaseData);
          }
        })
        .catch((err: BusinessError) => {
          this.memberParams.status = FinishStatus.UNFINISHED;
          this.memberParams.purchaseTime = Date.now();
          this.memberParams.errCode = err.code;
          this.memberParams.errMsg = err.message;
          this.subscribeCallBack(this.memberParams);
          UtilLog.error(0xFF00, 'MemberShip',
            `Failed to create purchase. Code is ${err.code}, message is ${err.message}`);
          if (err.code === iap.IAPErrorCode.PRODUCT_OWNED) {
            this.queryPurchase();
          }
        });
    } catch (e) {
      UtilLog.error(0xFF00, 'MemberShip', `Failed to buy products. Code is ${e.code}, message is ${e.message}`);
    }
  }

  handleAutoRenewProductId(subPayload: string) {
    let subGroupStatusPayload = MemberStatusUtil.getSubGroupStatusPayload(subPayload);
    let lastSubscriptionStatus = subGroupStatusPayload?.lastSubscriptionStatus;
    if (!lastSubscriptionStatus || lastSubscriptionStatus.status !== '1') {
      return;
    }
    const purchaseOrderPayload = lastSubscriptionStatus.lastPurchaseOrder;
    if (purchaseOrderPayload === undefined) {
      return;
    }
    this.autoRenewProductId = purchaseOrderPayload.productId;
  }

  handleProductId(purchaseData: string) {
    let purchaseOrderPayload = MemberStatusUtil.getLastPurchaseOrder(purchaseData);
    let purchaseTime = 0;
    if (purchaseOrderPayload) {
      this.nonRenewProductId = purchaseOrderPayload?.productId;
      this.isMember = true;
      purchaseTime = purchaseOrderPayload.purchaseTime;
    }
    // 请求获取到期时间
    this.queryExpireTime(this.nonRenewProductId, purchaseTime).then((expireTime) => {
      this.lastPurchaseProductExpireTime = expireTime;
    });
  }

  dealPurchaseData(purchaseData: string) {
    // You are advised to send purchaseData to the app server for signature verification.
    let purchaseOrderPayload = MemberStatusUtil.getLastPurchaseOrder(purchaseData);
    // todo: 处理发货
    // ...
    // 发货成功后向IAP Kit发送finishPurchase请求，确认发货，完成购买
    if (purchaseOrderPayload && purchaseOrderPayload.finishStatus !== FinishStatus.FINISHED) {
      this.finishPurchase(purchaseOrderPayload);
    }
  }

  dealSubscribeData(purchaseData: string) {
    try {
      // You are advised to send purchaseData to the app server for signature verification.
      let subGroupStatusPayload = MemberStatusUtil.getSubGroupStatusPayload(purchaseData);
      this.groupId = subGroupStatusPayload?.subGroupId ?? '';
      let lastSubscriptionStatus = subGroupStatusPayload?.lastSubscriptionStatus;
      if (!lastSubscriptionStatus || lastSubscriptionStatus.status !== '1') {
        return;
      }
      const purchaseOrderPayload = lastSubscriptionStatus.lastPurchaseOrder;
      if (purchaseOrderPayload === undefined) {
        return;
      }
      // todo: 处理发货
      // ...
      // 发货成功后向IAP Kit发送finishPurchase请求，确认发货，完成购买
      this.finishPurchase(purchaseOrderPayload);
    } catch (e) {
      UtilLog.error(0xFF00, 'MemberShip', `Failed to deal purchase data. Code is ${e.code}, message is ${e.message}`);
    }
  }

  getExpiresTime(purchaseData: string) {
    try {
      let lastSubscriptionStatus = MemberStatusUtil.getLastSubscriptionStatus(purchaseData);
      if (lastSubscriptionStatus?.renewalInfo) {
        this.renewProductId = lastSubscriptionStatus?.renewalInfo.productId ?? '';
        this.expiresTime = lastSubscriptionStatus?.expiresTime ?? 0;
      }
    } catch (e) {
      UtilLog.error(0xFF00, 'MemberShip', `Failed to get renewal time. Code is ${e.code}, message is ${e.message}`);
    }
  }

  showHint(uiContext: UIContext, node: ComponentContent<Object>) {
    uiContext.getPromptAction().openCustomDialog(node, {
      levelMode: LevelMode.OVERLAY,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        UtilLog.info(0xFF00, 'MemberShip', JSON.stringify(dismissDialogAction.reason));
      },
    }).then(() => {
      UtilLog.info(0xFF00, 'MemberShip', 'OpenCustomDialog completed');
    })
      .catch((error: BusinessError) => {
        let message = (error as BusinessError).message;
        let code = (error as BusinessError).code;
        UtilLog.info(0xFF00, 'MemberShip', `OpenCustomDialog args error code is ${code}, message is ${message}`);
      });
  }

  finishPurchase(purchaseOrder: PurchaseOrderPayload) {
    if (!purchaseOrder.productType) {
      return;
    }
    const finishPurchaseParam: iap.FinishPurchaseParameter = {
      productType: Number(purchaseOrder.productType),
      purchaseToken: purchaseOrder.purchaseToken,
      purchaseOrderId: purchaseOrder.purchaseOrderId,
    };
    iap.finishPurchase(this.uiContext?.getHostContext() as common.UIAbilityContext, finishPurchaseParam).then(() => {
      this.memberParams.status = FinishStatus.FINISHED;
      this.memberParams.purchaseTime = Date.now();
      this.userStatus.memberStatus.type = this.memberParams.type;
      this.subscribeCallBack(this.memberParams);
      if (this.memberParams.type === iap?.ProductType.NONCONSUMABLE) {
        iap.isSandboxActivated(this.uiContext?.getHostContext()).then((res) => {
          if (res) {
            this.uiContext?.getPromptAction().showToast({
              message: '由于沙盒场景下非消耗型商品订单信息不返回，购买状态无法刷新，请在真实环境下测试',
            });
          }
        });
      }
      // 购买完成刷新页面
      this.queryPurchase();
      UtilLog.info(0xFF00, 'MemberShip', `Succeeded in finishing purchase.`);
    }).catch((err: BusinessError) => {
      UtilLog.error(0xFF00, 'MemberShip', `Failed to buy products. Code is ${err.code}, message is ${err.message}`);
    });
  }

  getProductIds(productsInfo: ProductInfo[], type: iap.ProductType) {
    let productIds: string[] = [];
    productIds = productsInfo.map((item => {
      if (item.type === type) {
        return item.productId;
      } else {
        return '';
      }
    }));
    return productIds.filter((item) => item);
  }

  queryProducts(productsInfo: ProductInfo[]) {
    this.productInfoList = [];
    try {
      this.loading = true;
      const renewProductParam: iap.QueryProductsParameter = {
        productType: iap.ProductType.AUTORENEWABLE,
        productIds: this.getProductIds(productsInfo, iap?.ProductType.AUTORENEWABLE),
      };

      const nonRenewProductParam: iap.QueryProductsParameter = {
        productType: iap.ProductType.NONRENEWABLE,
        productIds: this.getProductIds(productsInfo, iap?.ProductType.NONRENEWABLE),
      };

      const nonConsumeProductParam: iap.QueryProductsParameter = {
        productType: iap.ProductType.NONCONSUMABLE,
        productIds: this.getProductIds(productsInfo, iap?.ProductType.NONCONSUMABLE),
      };

      let promiseList: (Promise<Array<iap.Product>> | undefined)[] = [];

      for (let item of [renewProductParam, nonRenewProductParam, nonConsumeProductParam]) {
        promiseList.push(this.getPromiseList(item));
      }

      promiseList = promiseList.filter((item) => item);

      Promise.all(promiseList)
        .then((res) => {
          this.loading = false;
          for (let item of res) {
            this.productInfoList = [...this.productInfoList, ...item ?? []];
          }
        })
        .catch((err: BusinessError) => {
          this.loading = false;
          this.uiContext?.getPromptAction().showToast({
            message: `查询会员商品失败，错误码为${err.code}，请排查后重试~`,
            duration: 1000,
          });
          UtilLog.error(0xFF00, 'MemberShip',
            `Failed to query products. Code is ${err.code}, message is ${err.message}`);
        });
    } catch {
      this.loading = false;
    }
  }

  getPromiseList(params: iap.QueryProductsParameter) {
    let promise: Promise<Array<iap.Product>> | undefined = undefined;
    try {
      if (params.productIds.length) {
        promise = iap.queryProducts(this.uiContext?.getHostContext() as common.UIAbilityContext, params);
      }
      return promise;
    } catch (e) {
      return undefined;
    }
  }

  async queryPurchase() {
    // 查询是否有当前用户的会员购买记录
    this.loading = false;
    let memberList = await MemberStatusUtil.queryPurchase(this.uiContext?.getHostContext() as common.UIAbilityContext);
    this.ownedMemberCallBack(memberList);
    this.autoRenewPurchasedList = memberList.renewList;
    this.nonAutoRenewPurchasedList = memberList.nonRenewList;

    if (this.autoRenewPurchasedList?.length) {
      this.getExpiresTime(this.autoRenewPurchasedList[0]);
      this.isMember = true;
      this.isRenewMember = true;
    } else {
      this.isRenewMember = false;
    }
    if (this.autoRenewPurchasedList?.length) {
      // 展示最近一次的购买记录
      this.handleAutoRenewProductId(this.nonAutoRenewPurchasedList[0]);
    }

    if (this.nonAutoRenewPurchasedList?.length) {
      // 展示最近一次的购买记录
      this.handleProductId(this.nonAutoRenewPurchasedList[0]);
    }

    if (!this.nonAutoRenewPurchasedList?.length && !this.autoRenewPurchasedList?.length) {
      this.isMember = false;
    }
  }

  getFormatTime(time: number) {
    let date = new Date(time);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate()
      .toString()
      .padStart(2, '0')}`;
  }

  async getWindowAvoidArea(context: common.UIAbilityContext): Promise<number> {
    try {
      const mainWindow = await window.getLastWindow(context);
      const avoidAreaType = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
      const avoidArea = mainWindow.getWindowAvoidArea(avoidAreaType);
      const height = avoidArea.bottomRect.height;
      return this.uiContext?.px2vp(height) ?? 28;
    } catch (e) {
      UtilLog.error(0xFF00, 'MemberShip', `Failed to get avoid height. Code is ${e.code}, message is ${e.message}`);
      return 28;
    }
  }

  manageSubscribe(uIAbilityContext: common.UIAbilityContext) {
    const uiWindowParameter: iap.UIWindowParameter = {
      windowScreenMode: iap.WindowScreenMode.DIALOG_BOX,
    };
    iap.showManagedSubscriptions(uIAbilityContext, uiWindowParameter, this.groupId).then(() => {
      UtilLog.info(0xFF00, 'MemberShip', `Succeeded in showing subscription page.`);
    }).catch((err: BusinessError) => {
      UtilLog.error(0xFF00, 'MemberShip',
        `Failed to show subscription page. Code is ${err.code}, message is ${err.message}`);
    });
  }

  listenFoldChange() {
    try {
      display.on('foldStatusChange', (data: display.FoldStatus) => {
        this.foldStatus = data;
      });
    } catch (e) {
      UtilLog.error(0xFF00, 'MemberShip',
        `Failed to listen fold status change. Code is ${e.code}, message is ${e.message}`);
    }
  }

  listenScreenRotate() {
    try {
      display.on('change', async () => {
        // 获取当前旋转角度
        this.rotation = display.getDefaultDisplaySync().rotation;
      });
    } catch (e) {
      UtilLog.error(0xFF00, 'MemberShip',
        `Failed to listen screen rotate change. Code is ${e.code}, message is ${e.message}`);
    }
  }
}