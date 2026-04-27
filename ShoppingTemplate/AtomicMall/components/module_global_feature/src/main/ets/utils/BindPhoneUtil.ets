import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowUtil, iData, routerStack } from 'lib_foundation';
import { UserApis } from 'lib_network';
import { CommonConfirmDialog } from 'lib_widget';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[MallAccountUtil]';

const enum ErrorCodeMap {
  USER_CANCEL = 1001502012,
  NO_PERMISSION = 1001502014,
  EMULATOR = 804,
}

export interface BindPhoneParams {
  err?: BusinessError
  code?: string
  needBack?: boolean
  callback?: () => void
}

export class BindPhoneUtil {
  public static async handleBind(params: BindPhoneParams) {
    if (params.err?.code === ErrorCodeMap.USER_CANCEL) {
      UtilLog.error(TAG, 'get phone failed,err' + params.err.message);
      return;
    }
    if (params.code) {
      const res = await UserApis.login({ authorizationCode: params.code });
      if (res.code === 0) {
        BindPhoneUtil.bindPhoneSuccess(params);
      }
    } else {
      BindPhoneUtil.handleBindFailed(params);
    }
  }

  public static handleUnbind() {
    CommonConfirmDialog.show({
      content: '确认取消手机号关联吗？',
      confirm: async () => {
        await BindPhoneUtil.cancelAuthorization();
        UserApis.logout().then(() => {
          WindowUtil.toast('解除账号关联成功！');
          iData.global.userInfo.reset();
        });
      },
    });
  }

  public static async bindPhoneSuccess(params: BindPhoneParams) {
    WindowUtil.toast('手机号绑定成功');
    if (params.needBack) {
      routerStack.pop();
    }
    if (params.callback) {
      params.callback();
    }
  }

  public static handleBindFailed(params: BindPhoneParams) {
    if (params.err?.code) {
      let errMsg: string = '未知错误';
      if (params.err.code === ErrorCodeMap.NO_PERMISSION) {
        errMsg = '元服务未获取phone权限或用户授权';
      } else if (params.err.code === ErrorCodeMap.EMULATOR) {
        errMsg = '模拟器不支持关联功能';
      }
      CommonConfirmDialog.show({
        content: `${errMsg}, 此为模拟关联。是否先模拟关联成功？`,
        confirm: async () => {
          const res = await UserApis.login();
          if (res.code === 0) {
            BindPhoneUtil.bindPhoneSuccess(params);
          }
        },
      });
    }
  }

  public static async cancelAuthorization() {
    const cancelRequest: authentication.CancelAuthorizationRequest =
      new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
    cancelRequest.state = util.generateRandomUUID();
    try {
      const controller: authentication.AuthenticationController = new authentication.AuthenticationController();
      controller
        .executeRequest(cancelRequest)
        .then((data: authentication.AuthenticationResponse) => {
          const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
          const state: string = cancelAuthorizationResponse.state!;
          if (cancelRequest.state !== state) {
            UtilLog.error('Failed to cancel. The state is different');
            return;
          }
          UtilLog.debug(TAG, 'cancel authorization success');
        })
        .catch((err: BusinessError) => {
          UtilLog.error(`Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
        });
    } catch (err) {
      UtilLog.error(`Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
    }
  }
}