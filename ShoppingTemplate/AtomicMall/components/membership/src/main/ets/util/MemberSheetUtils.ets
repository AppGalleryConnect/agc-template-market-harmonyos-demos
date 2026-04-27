import { PopViewUtil } from 'module_ui_base';
import { DEFAULT_LOGIN_SHEET_HEIGHT } from '../constant/Constant';
import { MemberList, MemberParams, ProductInfo } from '../model/Index';

@Builder
function memberSheetBuilder(params: ProductsInfoOptions) {
  memberSheet({ params });
}

@ComponentV2
export struct memberSheet {
  @Param params: ProductsInfoOptions = new ProductsInfoOptions();
  @Local sheetStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.sheetStack.pushPathByName('MemberShipView', this.params as ProductsInfoOptions,
      undefined,
      true,
    );
  }

  build() {
    Navigation(this.sheetStack) {
    }
    .hideNavBar(true)
    .hideTitleBar(true);
  }
}

@ObservedV2
export class ProductsInfoOptions {
  isSheet: boolean = true;
  linearColors: Array<[
    ResourceColor,
    number
  ]> = [['#FFFFFF', 0.0], ['#E5EDF5', 0.5], ['#0A59F7', 1.0]];
  themeColor: ResourceStr = $r('sys.color.background_emphasize');
  lastPurchaseProductExpireTime: string = '';
  productsInfo: ProductInfo[] = [];
  privacyContent: string = '';
  subscribeCallBack: (params: MemberParams) => Promise<void> = () => new Promise(() => {
  });
  queryExpireTime: (productId: string, time?: number) => Promise<void> = () => new Promise(() => {
  });
  ownedMemberCallBack: (list: MemberList) => Promise<void> = () => new Promise(() => {
  });
}

export class MemberSheetUtils {
  static open(params: ProductsInfoOptions, uiContext: UIContext) {
    PopViewUtil.openSheet(wrapBuilder(memberSheetBuilder), {
      title: { title: '开通会员' },
      showClose: true,
      height: DEFAULT_LOGIN_SHEET_HEIGHT,
      backgroundColor: $r('sys.color.background_secondary'),
      preferType: SheetType.CENTER,
    }, params, uiContext);
  }

  static close() {
    PopViewUtil.closeSheet();
  }
}