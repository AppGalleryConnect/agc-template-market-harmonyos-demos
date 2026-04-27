import { PersistenceV2 } from '@kit.ArkUI';
import { UIDialog } from '@hw-agconnect/ui-dialog';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import {
  CommonUtil,
  Coupon,
  HttpApi,
  ToastLoading,
  UserInfoModel,
  RouterModule,
  RouterMap,
  EmitterUtils,
} from 'lib_foundation'
import { CouponCard, CouponItem, CouponStatus, ReductionTypes } from 'coupons';


// 兑换优惠券所需积分
const POINTS: number = 5;

@ComponentV2
export struct CouponListSection {
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local couponList: Coupon[] = [];
  @Local list: CouponItem[] = [];
  themeColor: ResourceColor = $r('sys.color.font_emphasize');

  aboutToAppear(): void {
    // 获取优惠券列表数据
    this.loadCouponList();

    EmitterUtils.once('refreshBenefitList', () => {
      // 获取优惠券列表数据
      this.loadCouponList();
    });
  }

  aboutToDisappear(): void {
    EmitterUtils.off('refreshBenefitList');
  }

  // 获取优惠券列表数据
  loadCouponList() {
    HttpApi.queryCouponTemplateList(this.userInfoModel.id).then((resp) => {
      if (resp.length > 0) {
        this.couponList = resp;
        this.handleCouponList();
      }
    }).finally(() => {
      ToastLoading.close()
    })
  }

  // 处理数据
  handleCouponList() {
    let couponsList: CouponItem[] = [];
    if (this.couponList.length > 0) {
      // 数据转换为优惠券组件需要的结构
      couponsList = this.couponList.map((item) => {
        const data = {
          couponID: item.id.toString(),
          couponName: item.name,
          couponStatus: item.couponStatus as CouponStatus,
          usageRestriction: item.usageRestriction,
          startTime: CommonUtil.formatDate(item.startTime, 'YYYY-MM-DD'),
          endTime: CommonUtil.formatDate(item.endTime, 'YYYY-MM-DD'),
          createdTime: CommonUtil.formatDate(item.createdTime, 'YYYY-MM-DD'),
          amountRule: {
            discountType: item.discountType as ReductionTypes,
            fullAmount: item.fullAmount.toString(),
            discountAmount: item.discountAmount.toString(),
            discountCoefficient: item.discountCoefficient.toString(),
          },
        } as CouponItem;
        return data
      })
    }
    this.list = couponsList;
  }

  // 领取优惠券逻辑处理
  handleClaimCoupon(coupon: CouponItem) {
    const couponId = Number(coupon.couponID);
    const isPointsRedeem = coupon?.couponName.includes('兑换') || coupon?.usageRestriction.includes('兑换');
    // 积分兑换
    if (isPointsRedeem) {
      this.pointsRedeem(couponId);
      return;
    }
    // 领取
    const isMemberOnly = coupon?.usageRestriction.includes('会员');
    // 所有人都可以领取
    if (!isMemberOnly) {
      this.claimCoupon(couponId);
      return
    }
    // 如果是会员，则领取，否则跳转到会员开通页
    if (this.userInfoModel.isVip) {
      this.claimCoupon(couponId);
    } else {
      RouterModule.push({ url: RouterMap.PURCHASE_PAGE });
    }
  }

  // 积分兑换
  pointsRedeem(couponId: number) {
    // 统一使用5积分兑换
    if (this.userInfoModel.points < POINTS) {
      ToastDialog.showToast({
        message: '用户积分不足，无法兑换',
        toastAlignment: DialogAlignment.Center,
      })
      return;
    }
    UIDialog.open({
      content: '是否确认兑换优惠券，兑换后不可撤销',
      showConfirmButton: true,
      showCancelButton: true,
      confirmButtonOptions: {
        button: '我再想想',
        buttonFontColor: $r('sys.color.font_secondary'),
        buttonFontSize: 16,
        buttonBgColor: Color.Transparent,
      },
      cancelButtonOptions: {
        button: '确认兑换',
        buttonFontColor: $r('sys.color.font_emphasize'),
        buttonFontSize: 16,
        buttonBgColor: Color.Transparent,
      },
      onCancel: () => {
        this.claimCoupon(couponId, true);
      },
      closeOnClickMask: false,
      closeOnBackPress: false,
    })
  }

  claimCoupon(couponId: number, isPoints: boolean = false) {
    ToastLoading.open();
    const tip = isPoints ? '兑换' : '领取';
    HttpApi.claimCoupon(this.userInfoModel.id, couponId).then((resp) => {
      if (resp) {
        ToastDialog.showToast({ message: `优惠券${tip}成功！` });
        this.loadCouponList();

        // 如果是积分兑换，需要将用户积分更新
        if (isPoints) {
          HttpApi.changeUserPoints(this.userInfoModel.id, -POINTS, '兑换优惠券').then(() => {
            this.userInfoModel.points -= POINTS;
          })
        }
      }
    }).catch(() => {
      ToastLoading.close();
      ToastDialog.showToast({ message: `优惠券${tip}失败，请稍后再试` });
    })
  }

  getText(ri: RepeatItem<CouponItem>) {
    const coupon = this.couponList.find((x) => x.id.toString() === ri.item.couponID);
    if (coupon?.receivedId) {
      return '已领取';
    }
    // 积分兑换
    return coupon?.name.includes('兑换') || coupon?.usageRestriction.includes('兑换') ? '立即兑换' : '立即领取'
  }

  getEnabled(ri: RepeatItem<CouponItem>) {
    const coupon = this.couponList.find((x) => x.id.toString() === ri.item.couponID);
    return !Boolean(coupon?.receivedId);
  }

  build() {
    List({ space: 12 }) {
      Repeat(this.list)
        .each((couponInfo: RepeatItem<CouponItem>) => {
          ListItem() {
            CouponCard({
              coupon: couponInfo.item,
              totalMoney: 0,
              isAvailable: true,
              themeColor: this.themeColor,
              actionSlot: (status: number) => {
                this.couponActionBuilder(couponInfo);
              },
            })
          }
        })
        .key((item) => JSON.stringify(item))
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .contentEndOffset(12)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
  }

  @Builder
  couponActionBuilder(ri: RepeatItem<CouponItem>) {
    Button() {
      Text(this.getText(ri))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(400)
        .fontColor($r('sys.color.font_on_primary'))
        .lineHeight(19)
    }
    .type(ButtonType.Capsule)
    .width(72)
    .height(28)
    .enabled(this.getEnabled(ri))
    .backgroundColor(this.themeColor)
    .onClick(() => {
      if (ri.item) {
        this.handleClaimCoupon(ri.item)
      }
    })
  }
}