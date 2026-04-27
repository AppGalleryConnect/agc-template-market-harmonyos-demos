import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { iap } from '@kit.IAPKit';
import { UIDialog } from '@hw-agconnect/ui-dialog';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { FinishStatus, MemberList, MemberParams, MemberShipPage } from 'membership';
import {
  BreakpointModel,
  CommonUtil,
  ControllerModule,
  EmitterUtils,
  HttpApi,
  RouterMap,
  RouterModule,
  ToastLoading,
  User,
  UserInfoModel,
} from 'lib_foundation';
import { PRIVACY_CONTENT, PRODUCTS_INFO } from '../constants';


@Builder
export function PurchasePageBuilder() {
  PurchasePage();
}

@ComponentV2
export struct PurchasePage {
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local expireDate: string = '';
  // 不再提醒领取权益
  @Local isNotRemindAgain: boolean = false;
  subscribeEvent = async (params: MemberParams): Promise<void> => {
    if (params.type === iap.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {
      // 会员开通
      this.subscribeMembership();
    }
  };
  ownedMemberEvent = async (list: MemberList): Promise<void> => {
    if (list.renewList.length || list.nonRenewList.length) {
      // 查询会员信息
      this.getMembershipInfo();
    }
  };
  queryExpireTime = (productId: string, time?: number): Promise<void> => {
    // 请求开发者服务器获取非周期订阅商品到期时间（涉及商品id、购买次数）
    return new Promise(() => {
      this.getExpireDate();
    })
  };

  // 订阅成功，更新用户的会员状态
  subscribeMembership() {
    const curExpireTime = this.userInfoModel.vipExpireTime;
    const nextYearTimestamp = new Date().setFullYear(new Date(curExpireTime).getFullYear() + 1);
    const data = {
      userId: this.userInfoModel.id,
      isVip: 1,
      vipExpireTime: nextYearTimestamp,
    } as User;
    HttpApi.updateUserInfo(data).then(async () => {
      this.userInfoModel.isVip = true;
      this.userInfoModel.vipExpireTime = nextYearTimestamp;
      this.getExpireDate();

      // 是否领取会员权益
      if (!this.userInfoModel.isClaimBenefit) {
        const hasUnClaimedCoupon = await HttpApi.hasUnclaimedMemberCoupons(this.userInfoModel.id);
        if (hasUnClaimedCoupon) {
          this.openBenefitDialog();
        } else {
          this.userInfoModel.isClaimBenefit = true;
        }
      }
      ToastDialog.showToast({ message: '会员订阅成功！' });
    })
  }

  // 查会员信息
  async getMembershipInfo() {
    // 会员超期时间
    this.getExpireDate();
    // 是否领取会员权益
    if (!this.userInfoModel.isClaimBenefit) {
      const hasUnClaimedCoupon = await HttpApi.hasUnclaimedMemberCoupons(this.userInfoModel.id);
      // 存在未领取的会员权益优惠券
      if (hasUnClaimedCoupon && !this.isNotRemindAgain) {
        this.openBenefitDialog();
        return
      }
      // 没有未领取的会员权益优惠券
      if (!hasUnClaimedCoupon) {
        const data = {
          userId: this.userInfoModel.id,
          isClaimBenefit: 1,
        } as User;
        // 更新用户会员权益领取状态
        HttpApi.updateUserInfo(data);
        this.userInfoModel.isClaimBenefit = true;
      }
    }
  }

  // 获取超期时间
  getExpireDate() {
    const expireTime = this.userInfoModel.vipExpireTime;
    this.expireDate = CommonUtil.formatDate(expireTime, 'YYYY-MM-DD');
  }

  openBenefitDialog() {
    UIDialog.open({
      contentBuilder: () => {
        this.contentBuilder()
      },
      showConfirmButton: false,
      showCancelButton: false,
      closeOnClickMask: false,
      closeOnBackPress: false,
    })
  }

  build() {
    NavDestination() {
      MemberShipPage({
        routerModule: RouterModule.stack,
        themeColor: $r('sys.color.background_emphasize'),
        linearColors: [['#E5EDF5', 0], ['#0A59F7', 1.0]],
        isSheet: false,
        lastPurchaseProductExpireTime: this.expireDate,
        productsInfo: PRODUCTS_INFO,
        privacyContent: PRIVACY_CONTENT,
        subscribeCallBack: this.subscribeEvent,
        queryExpireTime: this.queryExpireTime,
        ownedMemberCallBack: this.ownedMemberEvent,
      })
    }
    .hideTitleBar(true)
    .padding({ bottom: this.breakPointModel.pagePadding })
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Builder
  contentBuilder() {
    Column() {
      Text('您有会员权益待领取')

      Button('一键领取')
        .type(ButtonType.Capsule)
        .width('100%')
        .margin({ top: 24 })
        .onClick(() => {
          ToastLoading.open();
          // 一键领取会员优惠券
          HttpApi.claimMemberBenefitCoupons(this.userInfoModel.id).then(() => {
            const data = {
              userId: this.userInfoModel.id,
              isClaimBenefit: 1,
            } as User;
            // 更新用户会员权益领取状态
            HttpApi.updateUserInfo(data).then(() => {
              UIDialog.closeLast();
              this.userInfoModel.isClaimBenefit = true;
              EmitterUtils.emit('refreshBenefitList');
              const controller = ControllerModule.get();
              if (controller) {
                controller.changeIndex(2);
              }
              RouterModule.popToName(RouterMap.MAIN_ENTRY);
            }).finally(() => {
              ToastLoading.close();
            })
          }).finally(() => {
            ToastLoading.close();
          })
        })
      Button('我再想想')
        .type(ButtonType.Capsule)
        .width('100%')
        .fontColor($r('sys.color.font_tertiary'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .margin({ top: 8 })
        .onClick(() => {
          // 下次不再提醒
          this.isNotRemindAgain = true;
          UIDialog.closeLast();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }
}