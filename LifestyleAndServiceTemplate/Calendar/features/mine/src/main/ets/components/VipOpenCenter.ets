import { iap } from '@kit.IAPKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { RouterModule } from 'router_module';
import { FinishStatus, MemberList, MemberParams, MemberShipPage } from 'membership';
import { PackageConstants } from '../constants/PackageConstants';
import { EMITTER_TYPE, UserState } from 'common';

@Builder
export function VipOpenCenterBuilder() {
  VipOpenCenter()
}

@ComponentV2
export struct VipOpenCenter {
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;
  @Local lastPurchaseProductExpireTime: string = '';
  subscribeEvent = async (params: MemberParams): Promise<void> => {
    emitter.emit('member_subscribe')
    if (params.type === iap.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {
      this.queryExpireTime(params.productId, params.purchaseTime);
    }
  };
  ownedMemberEvent = async (list: MemberList): Promise<void> => {
    if (list.renewList.length || list.nonRenewList.length) {
      this.getUIContext().getPromptAction().showToast({ message: `您已拥有会员` });
    }
  };
  queryExpireTime = (productId: string, time?: number): Promise<void> => {
    // 请求开发者服务器获取非周期订阅商品到期时间（涉及商品id、购买次数）
    return new Promise(() => {
      this.lastPurchaseProductExpireTime = 'xxxx-xx-xx';
    });
  };

  aboutToDisappear(): void {
    try {
      emitter.off(EMITTER_TYPE.WX_PAY)
    } catch (e) {
      UtilLog.error('emitter off error' + JSON.stringify(e))
    }
  }

  build() {
    NavDestination() {
      MemberShipPage({
        routerModule: RouterModule.getStack(),
        isSheet: false,
        btnFontColor: $r('sys.color.font_on_primary'),
        themeColor: '#D3B685',
        linearColors: [['#F4EAD8', 0.2], ['#F2D5AC', 1.0]],
        lastPurchaseProductExpireTime: this.lastPurchaseProductExpireTime,
        productsInfo: PackageConstants.packageInfo,
        privacyContent: PackageConstants.PRIVACY_CONTENT,
        subscribeCallBack: this.subscribeEvent,
        queryExpireTime: this.queryExpireTime,
        ownedMemberCallBack: this.ownedMemberEvent,
      });
    }
    .padding({ bottom: Number(AppStorage.get('bottomRectHeight')) })
    .hideTitleBar(true)
  }
}