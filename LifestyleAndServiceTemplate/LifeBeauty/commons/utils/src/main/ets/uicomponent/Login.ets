import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonUtils } from '../common/Utils';
import { Logger } from '../common/Logger';
import {
  bindMobileWithCode,
  confirmRebindMobileWithSecret,
  getUserInfo,
  loginWithHuaweiID,
  unbindMobile,
} from '../http/ApiManage';
import { DialogRebindBuilder, RebindParams } from './DialogReBind';
import { PopViewUtils } from '../common/PopViewUtils';
import { CancelBindParams, DialogCancelBindBuilder } from './DialogCancelBind';
import { AppStorageMap, CurAppInfo } from '../common/Constant';
import { AppStorageBank } from '../model/Model';
import { util } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';

/**
 * 获取并设置用户信息
 */
export const queryUserInfo = async() => {
  try {
    const userInfo = await getUserInfo();
    AppStorageBank.updateUserInfo(userInfo);
  } catch (e) {
    Logger.error('queryUserInfo error:' + JSON.stringify(e));
  }
};

/**
 * 静默登录
 */
export const silentLogin = async (): Promise<Boolean> => {
  try {
    let loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    loginRequest.forceLogin = false;
    let controller = new authentication.AuthenticationController();
    return controller.executeRequest(loginRequest).then(async (data) => {
      const loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
      const loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data;
      Logger.info(`loginResponse=${JSON.stringify(loginWithHuaweiIDCredential)}`);

      const resp = await loginWithHuaweiID({
        clientId: CurAppInfo.CLIENT_ID,
        code: loginWithHuaweiIDCredential?.authorizationCode || '',
        idToken: loginWithHuaweiIDCredential?.idToken || '',
        openId: loginWithHuaweiIDCredential?.openID || '',
        unionId: loginWithHuaweiIDCredential?.unionID || '',
      });
      Logger.info('loginWithHuaweiID success, token:' + resp.token);
      AppStorage.setOrCreate(AppStorageMap.TOKEN, resp.token);
      await queryUserInfo();
      return true;
    }).catch((error: BusinessError) => {
      Logger.error('LoginWithHuaweiID executeRequest error: ' + JSON.stringify(error));
      if (error?.code === authentication.AuthenticationErrorCode.ACCOUNT_NOT_LOGGED_IN) {
        promptAction.showToast({ message: $r('app.string.need_login_in_setting') });
      } else {
        promptAction.showToast({ message: $r('app.string.login_in_error') });
      }
      return false;
    });
  } catch (e) {
    promptAction.showToast({ message: $r('app.string.login_in_error') });
    return false;
  }
}

/**
 * 取消授权，每次申请关联手机号都要拉起面板
 */
export function cancelAuthorization() {
  const cancelRequest: authentication.CancelAuthorizationRequest =
    new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
  cancelRequest.state = util.generateRandomUUID();
  try {
    const controller: authentication.AuthenticationController = new authentication.AuthenticationController();
    controller.executeRequest(cancelRequest).then((data: authentication.AuthenticationResponse) => {
      const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
      const state: string = cancelAuthorizationResponse.state!;
      if (cancelRequest.state !== state) {
        Logger.error('Failed to cancel. The state is different');
        return;
      }
    }).catch((err: BusinessError) => {
      Logger.error(`Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
    })
  } catch (err) {
    Logger.error(`Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
  }
}

/**
 * 关联手机号
 */
export const bindPhone = async (code: string | undefined, onBind?: () => void) => {
  if (!code) {
    return;
  }
  try {
    const resp = await bindMobileWithCode(code);

    // 涉及确认换绑
    if (resp.rebindSecret) {
      const rebindPhone = async () => {
        try {
          await confirmRebindMobileWithSecret(resp.rebindSecret);
          if (onBind) {
            onBind();
          }
          cancelAuthorization();
          queryUserInfo();
        } catch (e) {
          cancelAuthorization();
          Logger.error('ReBindPhone error:' + JSON.stringify(e));
          promptAction.showToast({ message: $r('app.string.bind_phone_error') });
        }
      };

      const cancelCB = () => {
        cancelAuthorization();
      };

      PopViewUtils.showPopView<RebindParams>(wrapBuilder(DialogRebindBuilder),
        new RebindParams(rebindPhone, cancelCB),
        { alignment: DialogAlignment.Center });
    } else {
      if (onBind) {
        onBind();
      }
      cancelAuthorization();
      queryUserInfo();
    }
  } catch (e) {
    cancelAuthorization();
    Logger.error('BindPhone error:' + JSON.stringify(e));
    promptAction.showToast({ message: $r('app.string.bind_phone_error') });
  }
};

/**
 * 解绑手机号
 */
export const unbindPhone = () => {
  try {
    const unbind = async () => {
      await unbindMobile();
      queryUserInfo();
    };
    PopViewUtils.showPopView<CancelBindParams>(wrapBuilder(DialogCancelBindBuilder),
      new CancelBindParams(unbind),
      { alignment: DialogAlignment.Center });
  } catch (e) {
    Logger.error('unbindPhone error: ' + JSON.stringify(e));
    promptAction.showToast({ message: $r('app.string.unbind_phone_error') });
  }
};


/**
 * 登录按钮样式1
 */
@ComponentV2
export struct LoginButton {
  onBind?: () => void = () => {
  };

  build() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: $r('app.string.bind_phone_btn'),
          styleOption: {
            plain: true,
            styleConfig: new functionalButtonComponentManager
              .ButtonConfig()
              .type(ButtonType.Normal)
              .size({ height: 16 })
              .borderRadius(0)
              .padding(0)
              .fontSize(12)
              .fontColor(Color.Black)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(Color.Transparent)
              .borderWidth({ bottom: 1 }),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController()
          .onGetPhoneNumber((err, data) => {
            if (err) {
              CommonUtils.showErrorMessage(err);
              return;
            }
            Logger.info('succeeded in getting phone number. data.code = ' + data.code);
            bindPhone(data.code, this.onBind);
          }),
      }).id('phoneFunctionalButtonId1')
    }
  }
}

/**
 * 登录按钮样式2
 */
@ComponentV2
export struct LoginButtonType2 {
  @Event onBind?: () => void = () => {
  };

  build() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: $r('app.string.good_card_appoint_btn'),
          styleOption: {
            styleConfig: new functionalButtonComponentManager
              .ButtonConfig()
              .fontSize(14)
              .fontWeight(500)
              .fontColor($r('app.color.common_fg_white'))
              .backgroundColor($r('app.color.common_theme_color'))
              .size({ height: 28, width: 72 }),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController()
          .onGetPhoneNumber((err, data) => {
            if (err) {
              CommonUtils.showErrorMessage(err);
              return;
            }
            Logger.info('succeeded in getting phone number. data.code = ' + data.code);
            bindPhone(data.code, this.onBind);
          }),
      }).id('phoneFunctionalButtonId2')
    }
  }
}

/**
 * 登录按钮样式3
 */
@ComponentV2
export struct LoginButtonType3 {
  @Event onBind?: () => void = () => {
  };

  build() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: $r('app.string.book_good_btn'),
          styleOption: {
            styleConfig: new functionalButtonComponentManager
              .ButtonConfig()
              .width('100%')
              .fontSize(14)
              .fontColor($r('app.color.common_fg_white'))
              .backgroundColor($r('app.color.common_theme_color')),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController()
          .onGetPhoneNumber((err, data) => {
            if (err) {
              CommonUtils.showErrorMessage(err);
              return;
            }
            Logger.info('succeeded in getting phone number. data.code = ' + data.code);
            bindPhone(data.code, this.onBind);
          }),
      }).id('phoneFunctionalButtonId3')
    }
  }
}


/**
 * 登录按钮样式4
 */
@ComponentV2
export struct LoginButtonType4 {
  @Event onBind?: () => void = () => {
  };

  build() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: '抢购',
          styleOption: {
            styleConfig: new functionalButtonComponentManager
              .ButtonConfig()
              .fontSize(14)
              .fontColor($r('app.color.common_fg_white'))
              .backgroundColor($r('app.color.common_theme_color'))
              .size({ height: 28, width: 72 }),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController()
          .onGetPhoneNumber((err, data) => {
            if (err) {
              CommonUtils.showErrorMessage(err);
              return;
            }
            Logger.info('succeeded in getting phone number. data.code = ' + data.code);
            bindPhone(data.code, this.onBind);
          }),
      }).id('phoneFunctionalButtonId4')
    }
  }
}

/**
 * 登录按钮样式5
 */
@ComponentV2
export struct LoginButtonType5 {
  @Event onBind?: () => void = () => {
  };

  build() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: '立即抢购',
          styleOption: {
            styleConfig: new functionalButtonComponentManager
              .ButtonConfig()
              .fontSize(14)
              .fontColor($r('app.color.common_fg_white'))
              .backgroundColor($r('app.color.common_theme_color'))
              .size({ height: 40, width: 120 }),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController()
          .onGetPhoneNumber((err, data) => {
            if (err) {
              CommonUtils.showErrorMessage(err);
              return;
            }
            Logger.info('succeeded in getting phone number. data.code = ' + data.code);
            bindPhone(data.code, this.onBind);
          }),
      }).id('phoneFunctionalButtonId5')
    }
  }
}