import { CommonConstants, RouterModule } from 'commonlib';
import { iap } from '@kit.IAPKit';
import { FinishStatus, MemberList, MemberParams, MemberShipPage } from 'membership';
import { AppStorageV2 } from '@kit.ArkUI';
import { UserInfo } from 'login_info';

@Builder
export function MemberCenterPageBuilder() {
  MemberCenterPage();
}

@Preview
@ComponentV2
struct MemberCenterPage {
  @Local lastPurchaseProductExpireTime: string = '';
  @Local logoUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;


  aboutToAppear(): void {
  }

  subscribeEvent = async (params: MemberParams): Promise<void> => {
    this.getUIContext().getPromptAction().showToast({ message: this.getSubscribeMsg(params) });
    if (params.type === iap.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {
      this.queryExpireTime(params.productId, params.purchaseTime);
    }
  };
  ownedMemberEvent = async (list: MemberList): Promise<void> => {
    const isMembership = list.renewList.length > 0 || list.nonRenewList.length > 0;
    this.logoUser.isMembership = isMembership;
  };
  queryExpireTime = (productId: string, time?: number): Promise<string> => {
    // 请求开发者服务器获取非周期订阅商品到期时间（涉及商品id、购买次数）
    return new Promise((resolve, reject) => {
      this.lastPurchaseProductExpireTime = 'xxxx-xx-xx';
      resolve(this.lastPurchaseProductExpireTime)
    });
  };

  getSubscribeMsg(param: MemberParams) {
    let message = '';
    if (param.status === FinishStatus.FINISHED) {
      message = '会员订阅成功';
      this.logoUser.isMembership = true;
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
          linearColors: [['#fff6dcb7', 0.5], ['#E39331', 1.0]],
          btnFontColor: '#FFFFFF ',
          isSheet: false,
          lastPurchaseProductExpireTime: this.lastPurchaseProductExpireTime,
          productsInfo: CommonConstants.PRODUCTS_INFO,
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

