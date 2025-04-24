import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { commonToast } from '../utils/Toast';
import { CloudFunction } from '../cloudFunction/CloudFunction';
import { CloudFunctionUserResult, UserInfo } from '../model/CommonInterface';
import fs from '@ohos.file.fs';

export function getQuickLoginAnonymousPhone(context: Context,
  callback: (isLogin: boolean, userInfo: UserInfo) => void = () => {
  }) {
  // 创建授权请求，并设置参数
  const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
  // 获取手机号需要传如下scope，传参数之前需要先申请对应scope权限,才能返回对应数据
  authRequest.scopes = ['phone'];
  // 获取code需传如下permission
  authRequest.permissions = ['serviceauthcode'];
  // 用户是否需要登录授权，该值为true且用户未登录或未授权时，会拉起用户登录或授权页面
  authRequest.forceAuthorization = true;
  // 用于防跨站点请求伪造
  authRequest.state = util.generateRandomUUID();
  try {
    commonToast.show({
      type: 'loading',
    })
    const controller = new authentication.AuthenticationController(context);
    controller.executeRequest(authRequest).then((data) => {
      const authorizationWithHuaweiIDResponse = data as authentication.AuthorizationWithHuaweiIDResponse;
      const state = authorizationWithHuaweiIDResponse.state;
      if (state !== undefined && authRequest.state !== state) {
        hilog.error(0x0000, 'testTag', `Failed to authorize. The state is different, response state: ${state}`);
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in authentication.');
      const authorizationWithHuaweiIDCredential = authorizationWithHuaweiIDResponse.data!;
      const code = authorizationWithHuaweiIDCredential.authorizationCode;
      // 开发者处理code
      if (code) {
        /*
           * 获取到unionID以及idToken之后，使用云函数获取用户信息
           * 云函数、云数据库开发指导 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/cloudfoundation-introduction-V5
           * 已获取到的unionID为例
           * */
        CloudFunction.getUserInfo(code).then((userInfo) => {
          commonToast.hideAll()
          if ((userInfo as CloudFunctionUserResult).result.ret.code === 0) {
            let userInfoRes: UserInfo = (userInfo as CloudFunctionUserResult).result.result[0]
            userInfoRes.userName = userInfoRes.userName ? userInfoRes.userName : '华为用户'
            callback(true, new UserInfo(userInfoRes))
          }
        }).catch((err: BusinessError) => {
          commonToast.hideAll()
          promptAction.showToast({ message: '获取用户信息失败！' })
        })
      } else {
        promptAction.showToast({ message: '获取用户信息失败！' })
      }
    }).catch((err: BusinessError) => {
      dealAllError(err);
    })
  } catch (error) {
    dealAllError(error);
  }

}

export function cancelRelative(context: Context,
  callback: (state: string) => void = () => {
  }) {
  // 创建取消授权请求，并设置参数
  const cancelRequest = new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
  cancelRequest.state = util.generateRandomUUID(); // 建议使用generateRandomUUID生成state

  // 执行取消授权请求，并处理结果
  try {
    const controller = new authentication.AuthenticationController(context);
    controller.executeRequest(cancelRequest, (error: BusinessError<Object>, data) => {
      if (error) {
        dealAllError(error);
        return;
      }
      const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
      const state = cancelAuthorizationResponse.state;
      if (state && cancelRequest.state !== state) {
        hilog.error(0x0000, 'testTag', `Failed to cancel. The state is different, response state: ${state}`);
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in canceling.');
      callback('succeeded')
    });
  } catch (error) {
    dealAllError(error);
  }
}

// 错误处理
function dealAllError(error: BusinessError | BusinessError<Object>): void {
  commonToast.hideAll()
  hilog.error(0x0000, 'testTag', 'Failed to login, errorCode=%{public}d, errorMsg=%{public}s', error.code,
    error.message);
}