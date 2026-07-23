import { FinishStatus, MemberList, MemberParams, MemberSheetUtils, ProductsInfoOptions } from 'membership';
import { MemberCommonUtil } from 'mine';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';
import { iap } from '@kit.IAPKit';
import { CommonConstants, CommonUtil, RouterMap, RouterModule } from 'commonlib';


@ComponentV2
export struct VipTipView {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;

  // 通用会员 订阅事件
  subscribeEvent = async (params: MemberParams): Promise<void> => {
    MemberCommonUtil.subscribeEventLogger(params);
    if (params.type === iap.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {
      // 会员开通
      MemberCommonUtil.subscribeMembership(this.vm.userInfo);
      this.getExpireDate();
      MemberSheetUtils.close();
    }
  };

  // 通用会员 查询会员开通事件
  ownedMemberEvent = async (list: MemberList): Promise<void> => {
    await MemberCommonUtil.ownedMemberEvent(
      list,
      () => {
        this.vm.userInfo.isVip = true;
        MemberCommonUtil.showToast(this.getUIContext(), `您已拥有会员`)
      },
      () => {
        this.vm.userInfo.isVip = false;
      },
    );
  };
  queryExpireTime = (productId: string, time?: number): Promise<string> => {
    // 请求开发者服务器获取非周期订阅商品到期时间（涉及商品id、购买次数）
    return new Promise(() => {
      this.getExpireDate();
    })
  };

  productsInfo: ProductsInfoOptions = MemberCommonUtil.createProductsInfoForSheet(
    this.subscribeEvent,
    this.queryExpireTime,
    this.ownedMemberEvent,
    '',
  );

  // 获取超期时间
  getExpireDate() {
    const expireTime = this.vm.userInfo.vipExpireTime;
    this.vm.lastPurchaseProductExpireTime = CommonUtil.formatDate(expireTime, 'YYYY-MM-DD');
  }

  // 打开会员开通页面（根据登录状态处理）
  openMemberSheet() {
    const uiContext = this.getUIContext();
    if (this.vm.userInfo.isLogin) {
      MemberSheetUtils.open(this.productsInfo, uiContext);
    } else {
      RouterModule.push({
        url: RouterMap.LOGIN_PAGE,
        onPop: () => {
          MemberSheetUtils.open(this.productsInfo, uiContext);
        },
      });
    }
  }

  build() {
    Column() {
      Row({ space: CommonConstants.SPACE_S }) {
        Image($r('app.media.ic_wake'))
          .width(24)
        Text('会员专属效果，成为会员后可使用并保存')
          .fontSize(14)
          .fontColor(Color.White)

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontColor(['#e6ffffff'])
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
      }
      .backgroundColor($r('app.color.app_theme'))
      .borderRadius(20)
      .padding({
        left: CommonConstants.PADDING_M,
        right: CommonConstants.PADDING_M,
        top: CommonConstants.PADDING_S,
        bottom: CommonConstants.PADDING_S
      })
      .onClick(() => {
        this.openMemberSheet();
      });
    }
    .width(CommonConstants.FULL_PERCENT)
    .position({ top: 30 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .zIndex(10)
    .visibility(this.vm.showRemind && !this.vm.userInfo.isVip ? Visibility.Visible : Visibility.None)
  }
}