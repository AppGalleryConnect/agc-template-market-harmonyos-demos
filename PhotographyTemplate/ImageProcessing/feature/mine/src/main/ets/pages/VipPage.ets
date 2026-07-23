import { PersistenceV2 } from '@kit.ArkUI';
import { iap } from '@kit.IAPKit';
import { FinishStatus, MemberList, MemberParams, MemberShipPage } from 'membership';
import { CommonUtil, HttpApi, Logger, RouterModule, User, UserInfo} from 'commonlib'
import { MemberCommonUtil } from '../util/MemberCommonUtil';

@Builder
export function VipPageBuilder() {
  VipPage();
}


@ComponentV2
export struct VipPage {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local expireDate: string = '';

  subscribeEvent = async (params: MemberParams): Promise<void> => {
    MemberCommonUtil.subscribeEventLogger(params);
    if (params.type === iap.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {
      // 会员开通
      MemberCommonUtil.subscribeMembership(this.userInfo);
      this.getExpireDate();
    }
  };
  ownedMemberEvent = async (list: MemberList): Promise<void> => {
    await MemberCommonUtil.ownedMemberEvent(
      list,
      () => {
        MemberCommonUtil.showToast(this.getUIContext(), '您已拥有会员！');
        this.getExpireDate();
      },
      () => {
        MemberCommonUtil.showToast(this.getUIContext(), '会员已过期！');
      }
    );
  };
  queryExpireTime = (productId: string, time?: number): Promise<string> => {
    // 请求开发者服务器获取非周期订阅商品到期时间（涉及商品id、购买次数）
    return new Promise(() => {
      this.getExpireDate();
    })
  };

  // 获取超期时间
  getExpireDate() {
    const expireTime = this.userInfo.vipExpireTime;
    this.expireDate = CommonUtil.formatDate(expireTime, 'YYYY-MM-DD');
  }

build() {
    NavDestination() {
      MemberShipPage({
        routerModule: RouterModule.stack,
        themeColor: '#8981F7',
        linearColors: [['#C1BDF8', 0.5], ['#F1A5F0', 1.0]],
        btnFontColor: $r('sys.color.font_on_primary'),
        isSheet: false,
        lastPurchaseProductExpireTime: this.expireDate,
        productsInfo: MemberCommonUtil.PRODUCTS_INFO,
        privacyContent: MemberCommonUtil.PRIVACY_CONTENT,
        subscribeCallBack: this.subscribeEvent,
        queryExpireTime: this.queryExpireTime,
        ownedMemberCallBack: this.ownedMemberEvent,
      });

    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.comp_background_primary'))
  }
}