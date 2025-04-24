import { authentication } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { dealQuickLoginError } from './common/QuickLoginConstants';
import { showToast } from './common/ShowToast';
import { GlobalContext } from '../utils/GlobalContext';
import { CommonConstants } from '../constants/CommonConstants';

export class QuickLogin {
  static logTag: string = 'PrepareLoginPage';
  static domainId: number = 0x0000;

  // Obtain the anonymous mobile number.
  static getQuickLoginAnonymousPhone() {
    // Create an authorization request.
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // User information requested by the app.
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    // In the one-tap sign-in scenario, forceAuthorization must be set to false.
    authRequest.forceAuthorization = false;
    const controller = new authentication.AuthenticationController();
    try {
      controller.executeRequest(authRequest).then((response: authentication.AuthorizationWithHuaweiIDResponse) => {
        // Obtain the UnionID, OpenID, and anonymous mobile number.
        const unionID = response.data?.unionID;
        const openID = response.data?.openID;
        const quickLoginAnonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string;
        AppStorage.setOrCreate('quickLoginAnonymousPhone', quickLoginAnonymousPhone);
        QuickLogin.jumpLoginPage(quickLoginAnonymousPhone);
        hilog.info(QuickLogin.domainId, QuickLogin.logTag,
          `Succeeded in authorizing. QuickLoginAnonymousPhone is ${quickLoginAnonymousPhone}`);
      }).catch((error: BusinessError) => {
        hilog.error(QuickLogin.domainId, QuickLogin.logTag,
          `Failed to authorize. errCode is ${error.code}, errMessage is ${error.message}`);
        dealQuickLoginError(error);
        showToast(error);
      });
    } catch (error) {
      hilog.error(QuickLogin.domainId, QuickLogin.logTag,
        `Failed to authorize. errCode is ${error.code}, errMessage is ${error.message}`);
    }
  }

  // Redirect to another page.
  static jumpLoginPage(quickLoginAnonymousPhone: string) {
    if (quickLoginAnonymousPhone) {
      // Obtain the anonymous mobile number, pass it, and redirect to the one-tap sign-in screen.
      const params: Record<string, Object> = { 'anonymousPhone': quickLoginAnonymousPhone };

      let appPathStack = GlobalContext.getContext().getObject(CommonConstants.APP_PATH_STACK) as NavPathStack;
      appPathStack.pushPathByName('QuickLoginPage', params, true);
    } else {
      // If the anonymous mobile number cannot be obtained, an error message is displayed.
      const hint: string = getContext().resourceManager.getStringSync($r('app.string.get_mobile_number_error'));
      showToast(hint);
    }
  }
}