import { iap } from '@kit.IAPKit';
import { BreakpointSystem, routerStack, WindowUtil } from 'lib_foundation';
import { MembershipInfo, UserApis } from 'lib_network';
import { FinishStatus, MemberList, MemberParams, MemberSheetUtils, MemberShipPage } from 'membership';
import { PRIVACY_CONTENT, PRODUCTS_INFO } from '../commons/Constants';

@Builder
export function buildMemberSubscriptionPage() {
  MemberSubscriptionPage()
}

@ComponentV2
export struct MemberSubscriptionPage {
  @Local membershipInfo: MembershipInfo | undefined

  @Computed
  get expireDate() {
    return this.membershipInfo?.expireDate ?? ''
  }

  aboutToAppear(): void {
    if (BreakpointSystem.isTablet) {
      routerStack.pop()
      MemberSheetUtils.open({
        themeColor: $r('app.color.theme_color'),
        linearColors: [[$r('app.color.background_color_primary'), 0.0], [$r('app.color.theme_color'), 1.0]],
        isSheet: true,
        lastPurchaseProductExpireTime: this.expireDate,
        productsInfo: PRODUCTS_INFO,
        privacyContent: PRIVACY_CONTENT,
        subscribeCallBack: (params): Promise<void> => this.subscribeEvent(params),
        queryExpireTime: (): Promise<void> => this.getMembershipInfo(),
        ownedMemberCallBack: (list): Promise<void> => this.ownedMemberEvent(list),
      }, this.getUIContext());
    }
  }

  build() {
    NavDestination() {
      MemberShipPage({
        routerModule: routerStack.getActiveStack(),
        themeColor: $r('app.color.theme_color'),
        linearColors: [[$r('app.color.background_color_primary'), 0.0], ['#FFE64566', 1.0]],
        isSheet: false,
        lastPurchaseProductExpireTime: this.expireDate,
        productsInfo: PRODUCTS_INFO,
        privacyContent: PRIVACY_CONTENT,
        subscribeCallBack: (params): Promise<void> => this.subscribeEvent(params),
        queryExpireTime: (): Promise<void> => this.getMembershipInfo(),
        ownedMemberCallBack: (list): Promise<void> => this.ownedMemberEvent(list),
      });
    }.hideTitleBar(true)
  }

  async subscribeEvent(params: MemberParams) {
    if (params.type === iap.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {
      const res = await UserApis.subscribeMembership()
      if (res.code === 0) {
        WindowUtil.toast('会员订阅成功！')
        this.getMembershipInfo()
      }
    }
  };

  async ownedMemberEvent(list: MemberList) {
    if (!this.membershipInfo) {
      await this.getMembershipInfo()
    }
    if (list.nonRenewList.length && !this.membershipInfo?.isSubscribed) {
      UserApis.subscribeMembership()
    }
  };

  async getMembershipInfo() {
    const res = await UserApis.getMembershipInfo()
    if (res.code === 0) {
      this.membershipInfo = res.data;
    }
  }
}
