import { MemberShipPage } from '../pages/MemberShipPage';
import { ProductsInfoOptions } from '../util/MemberSheetUtils';

@ComponentV2
struct MemberShipView {
  @Local routerModule: NavPathStack = new NavPathStack();
  params: ProductsInfoOptions = new ProductsInfoOptions();

  build() {
    NavDestination() {
      MemberShipPage({
        routerModule: this.routerModule,
        isSheet: this.params.isSheet,
        themeColor: this.params.themeColor,
        linearColors: this.params.linearColors,
        btnFontColor: this.params.btnFontColor,
        lastPurchaseProductExpireTime: this.params.lastPurchaseProductExpireTime,
        productsInfo: this.params.productsInfo,
        privacyContent: this.params.privacyContent,
        subscribeCallBack: this.params.subscribeCallBack,
        queryExpireTime: this.params.queryExpireTime,
        ownedMemberCallBack: this.params.ownedMemberCallBack,
      });
    }.onReady((context) => {
      // 获取参数
      this.routerModule = context.pathStack;
      this.params = context.pathInfo.param as ProductsInfoOptions;
    });
  }
}

@Builder
export function MemberShipViewBuilder() {
  MemberShipView();
}