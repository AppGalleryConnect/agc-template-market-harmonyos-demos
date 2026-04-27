/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { authentication } from '@kit.AccountKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { CommonUtils } from 'module_base';
import {
  bindMobileWithCode,
  confirmRebindMobileWithSecret,
  getUserInfo,
  loginWithHuaweiID,
  unbindMobile,
} from '../http/ApiManage';
import { AppStorageMap, CurAppInfo } from '../common/Constant';
import { AppStorageBank, OpenId } from '../model/ObserveModel';
import { CommonConfirmDialog } from '../uicomponent/UIDialog';

const TAG = '[LoginUtil]';

/**
 * 登录工具类
 */
export class LoginUtil {
  /**
   * 静默登录
   */
  static async silentLogin(): Promise<Boolean> {
    try {
      let loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
      loginRequest.forceLogin = false;
      let controller = new authentication.AuthenticationController();
      return controller.executeRequest(loginRequest).then(async (data) => {
        const loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
        const loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data;
        Logger.info(TAG, `loginResponse=${JSON.stringify(loginWithHuaweiIDCredential)}`);

        const resp = await loginWithHuaweiID({
          clientId: CurAppInfo.CLIENT_ID,
          code: loginWithHuaweiIDCredential?.authorizationCode || '',
          idToken: loginWithHuaweiIDCredential?.idToken || '',
          openId: loginWithHuaweiIDCredential?.openID || '',
          unionId: loginWithHuaweiIDCredential?.unionID || '',
        });
        AppStorageBank.setOpenId(loginWithHuaweiIDCredential?.openID || '',)
        Logger.info(TAG, 'loginWithHuaweiID success, token:' + resp.token);
        AppStorage.setOrCreate(AppStorageMap.TOKEN, resp.token);
        await LoginUtil.queryUserInfo();
        return true;
      }).catch(async (error: BusinessError) => {
        Logger.error(TAG, 'LoginWithHuaweiID executeRequest error: ' + JSON.stringify(error));
        // 为了不阻塞模板体验，不做失败拦截
        await LoginUtil.queryUserInfo();
        return true;
      });
    } catch (e) {
      promptAction.showToast({ message: '华为账号登录异常，请稍后重试~' });
      return false;
    }
  }

  /**
   * 取消授权，每次申请关联手机号都要拉起面板
   */
  static cancelAuthorization() {
    const cancelRequest: authentication.CancelAuthorizationRequest =
      new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
    cancelRequest.state = util.generateRandomUUID();
    try {
      const controller: authentication.AuthenticationController = new authentication.AuthenticationController();
      controller.executeRequest(cancelRequest).then((data: authentication.AuthenticationResponse) => {
        const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
        const state: string = cancelAuthorizationResponse.state!;
        if (cancelRequest.state !== state) {
          Logger.error(TAG, 'Failed to cancel. The state is different');
          return;
        }
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
      })
    } catch (err) {
      Logger.error(TAG, `Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
    }
  }

  /**
   * 获取并设置用户信息
   */
  static async queryUserInfo() {
    try {
      const userInfo = await getUserInfo();
      AppStorageBank.updateUserInfo(userInfo);
    } catch (e) {
      Logger.error(TAG, 'queryUserInfo error:' + JSON.stringify(e));
    }
  }

  /**
   * 解绑手机号
   */
  static unBindPhone = () => {
    CommonUtils.showLoading();
    unbindMobile().then((linkStatus) => {
      AppStorageBank.setLinkState(linkStatus);
      LoginUtil.queryUserInfo();
      CommonUtils.hideLoading();
    }).catch((error: BusinessError) => {
      LoginUtil.cancelAuthorization();
      Logger.error(TAG, 'UnBindPhone error:' + JSON.stringify(error));
      promptAction.showToast({ message: '解绑手机号失败，请稍后重试~' });
    });
  }
  /**
   * 关联手机号
   */
  static bindPhone = async (code: string | undefined, onBind?: () => void) => {
    CommonUtils.showLoading();
    if (!code) {
      CommonUtils.hideLoading();
      return;
    }
    bindMobileWithCode(code).then((resp) => {
      AppStorageBank.setLinkState(true);
      if (resp.rebindSecret) {
        CommonUtils.hideLoading();
        const rebindPhone = async () => {
          try {
            CommonUtils.showLoading();
            await confirmRebindMobileWithSecret(resp.rebindSecret);
            if (onBind) {
              onBind();
            }
            LoginUtil.cancelAuthorization();
            LoginUtil.queryUserInfo();
            CommonUtils.hideLoading();
          } catch (e) {
            CommonUtils.hideLoading();
            LoginUtil.cancelAuthorization();
            Logger.error(TAG, 'ReBindPhone error:' + JSON.stringify(e));
            promptAction.showToast({ message: '解绑手机号失败，请稍后重试~' });
          }
        };

        const cancelCB = () => {
          LoginUtil.cancelAuthorization();
        };
        CommonConfirmDialog.show({
          content: '您提供的手机号码已与其他元服务用户关联，是否替换关联至当前元服务用户',
          confirmButton: '使用其他号码',
          cancelButton: '替换并关联',
          confirm: cancelCB,
          cancel: rebindPhone,
        })
      } else {
        if (onBind) {
          onBind();
        }
        LoginUtil.cancelAuthorization();
        LoginUtil.queryUserInfo();
      }
    }).catch((err: BusinessError) => {
      LoginUtil.cancelAuthorization();
      CommonUtils.hideLoading();
      Logger.error(TAG, 'BindPhone error:' + JSON.stringify(err));
      promptAction.showToast({ message: '关联手机号失败，请稍后重试~' });
    });
    CommonUtils.hideLoading();
  }
  /**
   * 获取手机号失败，模拟成功
   */
  static onGetPhoneNumberFail = (callback?: () => void) => {
    CommonConfirmDialog.show({
      contentBuilder: ContentBuilder,
      confirmButton: '确定',
      cancelButtonColor: $r('sys.color.font_emphasize'),
      cancelButton: '取消',
      confirm: () => {
        this.bindPhone('123', callback)
      },
    })
  }
}

@Builder
export function ContentBuilder() {
  Column() {
    Text('提示')
      .fontSize($r('sys.float.Title_S'))
      .fontWeight(FontWeight.Bold)
      .height(56)
    Text('元服务未获取phone权限或用户授权，点击确定创建一个mock账号')
      .fontSize($r('sys.float.Body_M'))
      .margin({ bottom: 8 })
  }
  .padding({ right: 24, left: 24 })
}

/**
 * 登录按钮样式Button
 */
@ComponentV2
export struct LoginBtnInCard {
  @Param btnHeight: Length = 28;
  @Param btnWidth: Length = 76;
  @Param fontSize: ResourceStr = $r('sys.float.Body_M');
  @Event onBind?: () => void = () => {
  };

  build() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: '预约',
          styleOption: {
            styleConfig: new functionalButtonComponentManager
              .ButtonConfig()
              .fontSize(this.fontSize)
              .fontWeight(500)
              .fontColor($r('sys.color.font_on_primary'))
              .backgroundColor($r('app.color.common_theme_color'))
              .size({ height: this.btnHeight, width: this.btnWidth })
              .constraintSize({ maxWidth: 448 })
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController()
          .onGetPhoneNumber((err, data) => {
            if (err) {
              Logger.error(TAG, 'fail to get phone number, error: ' + JSON.stringify(err));
              LoginUtil.onGetPhoneNumberFail(this.onBind);
              return;
            }
            Logger.info(TAG, 'succeeded in getting phone number. data.code = ' + data.code);
            LoginUtil.bindPhone(data.code, this.onBind);
          }),
      })
        .onClick(() => {
          // 阻断事件冒泡
        })
    }
  }
}

/**
 * 登录按钮样式Text
 */
@ComponentV2
export struct LoginBtnInMine {
  @Param btnHeight: Length = 28;
  @Param btnWidth: Length = 76;
  @Param fontSize: ResourceStr = $r('sys.float.Body_M');
  @Event onBind?: () => void = () => {
  };

  build() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: '',
          styleOption: {
            plain: true,
            hoverClass: functionalButtonComponentManager.HoverClassType.NONE,
            styleConfig: new functionalButtonComponentManager
              .ButtonConfig()
              .type(ButtonType.Normal)
              .fontSize(this.fontSize)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(500)
              .padding(0)
              .borderWidth(0)
              .size({ height: this.btnHeight, width: this.btnWidth })
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController()
          .onGetPhoneNumber((err, data) => {
            if (err) {
              Logger.error(TAG, 'fail to get phone number, error: ' + JSON.stringify(err));
              LoginUtil.onGetPhoneNumberFail(this.onBind);
              return;
            }
            Logger.info(TAG, 'succeeded in getting phone number. data.code = ' + data.code);
            LoginUtil.bindPhone(data.code, this.onBind);
          }),
      })
    }
  }
}