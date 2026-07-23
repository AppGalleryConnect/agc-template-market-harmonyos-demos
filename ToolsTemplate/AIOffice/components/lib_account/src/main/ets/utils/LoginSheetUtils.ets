import { GlobalContext, PopViewUtils, RouterMap, RouterUtils } from 'lib_common';
import { Constants } from '../constants/Constants';
import { LoginRouterParams, LoginSheetParams } from '../constants/Types';

@Builder
function loginSheetBuilder() {
  loginSheet()
}

@ComponentV2
struct loginSheet {
  @Local sheetParams: LoginSheetParams = LoginSheetUtils.sheetParams;
  @Local sheetStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.sheetStack = RouterUtils.createStack(Constants.LOGIN_SHEET_STACK_NAME, true);
    RouterUtils.pushPathByName(RouterMap.HUAWEI_LOGIN_PAGE, {
      isSheet: true,
      keepVM: false,
      sheetParams: this.sheetParams,
    } as LoginRouterParams,
      undefined,
      true,
      Constants.LOGIN_SHEET_STACK_NAME,
    );
  }

  build() {
    Navigation(this.sheetStack) {
    }
    .hideNavBar(true)
    .hideTitleBar(true)
    .height(this.sheetParams.height)
  }
}

/**
 * 统一登录半模态弹窗
 */
export class LoginSheetUtils {
  static sheetParams: LoginSheetParams = new LoginSheetParams();

  static open() {
    PopViewUtils.showSheet(wrapBuilder(loginSheetBuilder), {
      showClose: true,
      height: Constants.DEFAULT_LOGIN_SHEET_HEIGHT,
      detents: [Constants.DEFAULT_LOGIN_SHEET_HEIGHT, SheetSize.LARGE],
      dragBar: true,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      onHeightDidChange: (height: number) => {
        LoginSheetUtils.sheetParams.height =
          GlobalContext.getUIContext().px2vp(height);
      },
      onTypeDidChange: (type: SheetType) => {
        LoginSheetUtils.sheetParams.sheetType = type;
      },
    });
  }
}