import { AccountUtil, CommonConstants, RouterModule } from 'commonlib';
import { MemberCenterPageVM } from '../viewModels/MemberCenterPageVM';
import { iap } from '@kit.IAPKit';
import { FinishStatus, MemberList, MemberParams, MemberShipPage, ProductInfo } from 'membership';
import { PRODUCTS_INFO } from '../model/Index';

@Builder
export function MemberCenterPageBuilder() {
  MemberCenterPage();
}

@Preview
@ComponentV2
struct MemberCenterPage {
  vm: MemberCenterPageVM = new MemberCenterPageVM();

  aboutToAppear(): void {
    this.vm.getMemberPackages()
  }

  subscribeEvent = async (params: MemberParams): Promise<void> => {
    this.getUIContext().getPromptAction().showToast({ message: this.getSubscribeMsg(params) });
    if (params.type === iap.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {
      this.queryExpireTime(params.productId, params.purchaseTime);
    }
  };
  ownedMemberEvent = async (list: MemberList): Promise<void> => {
    const isMembership = list.renewList.length > 0 || list.nonRenewList.length > 0;
    AccountUtil.updateMembership(isMembership);
  };
  queryExpireTime = (productId: string, time?: number): Promise<void> => {
    // 请求开发者服务器获取非周期订阅商品到期时间（涉及商品id、购买次数）
    return new Promise(() => {
      this.vm.lastPurchaseProductExpireTime = 'xxxx-xx-xx';
    });
  };

  getSubscribeMsg(param: MemberParams) {
    let message = '';
    if (param.status === FinishStatus.FINISHED) {
      message = '会员订阅成功';
      AccountUtil.updateMembership(true);
    } else if (param.status === FinishStatus.UNFINISHED) {
      message = `会员订阅失败，订阅错误码为${param.errCode}，错误原因为${param.errMsg}`;
    }
    return message;
  }

  build() {
    NavDestination() {
      Stack() {
        MemberShipPage({
          routerModule: RouterModule.getStack(),
          themeColor: '#E39331',
          linearColors: [['#F8E6CE', 0.5], ['#E39331', 1.0]],
          btnFontColor: '#FFFFFF ',
          isSheet: false,
          lastPurchaseProductExpireTime: this.vm.lastPurchaseProductExpireTime,
          productsInfo: PRODUCTS_INFO,
          privacyContent: CommonConstants.PRIVACY_CONTENT,
          subscribeCallBack: this.subscribeEvent,
          queryExpireTime: this.queryExpireTime,
          ownedMemberCallBack: this.ownedMemberEvent,
        });
      }
    }
    .hideTitleBar(true)
    .padding({bottom: 20})
  }
}

