import { Logger, AccountUtil, RouterModule, DialogInfo, DialogMap } from 'commonlib';
import { https } from 'network';
import { promptAction } from '@kit.ArkUI';
import { ConfirmParam } from '../../dialog/CommonConfirmDialog';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = '[BindPhoneUtil]';

const ERROR_CODE_CANCEL = 1001502012;

export class BindPhoneUtil {
  public static async handleFunctionalButtonClick(err: BusinessError, code?: string) {
    if (err?.code === ERROR_CODE_CANCEL) {
      Logger.error(TAG, 'get phone failed,err' + err.message);
      return;
    }
    if (!code) {
      RouterModule.push({
        url: DialogMap.COMMON_CONFIRM,
        param: {
          title: '提示',
          message: '元服务未获取phone权限或用户授权，点击确定将根据openId创建一个mock账号。',
        },
        onPop: (value) => {
          const result = value.result as DialogInfo<ConfirmParam>;
          if (result.param?.isConfirm) {
            BindPhoneUtil._bindPhoneMock();
          }
        },
      });
    } else {
      BindPhoneUtil._bindPhone(code);
    }
  }


  public static async unbindPhone() {
    RouterModule.push({
      url: DialogMap.COMMON_CONFIRM,
      param: {
        title: '账号解除关联',
        message: '请确认是否解除关联？',
      },
      onPop: async (value) => {
        const result = value.result as DialogInfo<ConfirmParam>;
        if (result.param?.isConfirm) {
          await AccountUtil.cancelAuthorization();
          https.unBindPhone();
        }
      },
    });
  }

  private static async _bindPhoneMock() {
    try {
      const bindRes = await https.bindPhone('', true);
      if (bindRes.ret.code === 0) {
        AccountUtil.setUserInfo(bindRes.result);
        Logger.info(TAG, 'succeeded in getting phone number. ');
        promptAction.showToast({ message: '手机号绑定成功！当前手机号为mock数据，非华为账号真实手机号' });
        RouterModule.pop();
      }
    } catch (err) {
      promptAction.showToast({ message: '手机号绑定失败，请稍后重试' });
      Logger.error(TAG, 'bind phone and get user info error::' + JSON.stringify(err));
    }
  }

  private static async _bindPhone(code: string) {
    try {
      const bindRes = await https.bindPhone(code);
      if (bindRes.ret.code === 0) {
        AccountUtil.setUserInfo(bindRes.result);
        Logger.info(TAG, 'succeeded in getting phone number. ');
        promptAction.showToast({ message: '手机号绑定成功！' });
        RouterModule.pop();
      }
    } catch (err) {
      promptAction.showToast({ message: '手机号绑定失败，请稍后重试' });
      Logger.error(TAG, 'bind phone and get user info error::' + JSON.stringify(err));
    }
  }
}