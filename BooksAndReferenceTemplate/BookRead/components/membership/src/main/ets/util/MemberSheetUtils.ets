import { DEFAULT_LOGIN_SHEET_HEIGHT } from '../constant/Constant';
import { LoginApiController, MemberList, MemberParams, ProductInfo, UserStatus } from '../model/Index';
import { PopViewUtils } from './PopViewUtils';
import { common } from '@kit.AbilityKit';

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
  themeColor: ResourceColor = $r('sys.color.background_emphasize');
  btnFontColor: ResourceColor = $r('sys.color.font_on_primary');
  lastPurchaseProductExpireTime: string = '';
  productsInfo: ProductInfo[] = [];
  privacyContent: string = '';
  subscribeCallBack: (params: MemberParams) => Promise<void> = () => new Promise(() => {
  });
  queryExpireTime: (productId: string, time?: number) => Promise<string> = () => new Promise(() => {
  });
  ownedMemberCallBack: (list: MemberList) => Promise<void> = () => new Promise(() => {
  });
  loginApiController?: LoginApiController = new LoginApiController(() => new UserStatus(), () => {
  });
  isLinkLoginStatus?: boolean = false;
}

export class MemberSheetUtils {
  static open(params: ProductsInfoOptions, uiContext: UIContext) {
    PopViewUtils.showSheet(wrapBuilder(memberSheetBuilder), uiContext, {
      title: { title: '开通会员' },
      showClose: true,
      enableHoverMode: true,
      hoverModeArea: HoverModeAreaType.BOTTOM_SCREEN,
      height: DEFAULT_LOGIN_SHEET_HEIGHT,
      preferType: SheetType.CENTER,
      onHeightDidChange: (he: number) => {
        (uiContext.getHostContext() as common.UIAbilityContext).eventHub.emit('SheetHeightChange', he);
      },
      onWillDismiss: (dismissSheetAction: DismissSheetAction) => {
        (uiContext.getHostContext() as common.UIAbilityContext).eventHub.off('SheetHeightChange');
        dismissSheetAction.dismiss();
      },
    }, params);
  }

  static close() {
    PopViewUtils.closeSheet();
  }
}