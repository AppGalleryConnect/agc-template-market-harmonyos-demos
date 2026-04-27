import { BaseViewModel } from 'lib_common';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { UtilLog } from '@hw-agconnect/util-log';
import { promptAction, UIContext } from '@kit.ArkUI';
import { CommonTipDialog } from 'lib_common/src/main/ets/dialogs/CommonTipDialog';
import { MineServiceApi } from 'lib_tv_apis';

const TAG = '[MineVM]'

export class MineVM extends BaseViewModel {
  context: UIContext

  constructor(context: UIContext) {
    super()
    this.context = context
  }

  public toMultiAccount() {
    CommonTipDialog.show({
      primaryTitle: '账号解除关联',
      content: '请确认是否解除账号关联？',
      confirm: () => {
        this.cancelRelative()
      },
    })
  }

  public bindPhoneMock() {
    CommonTipDialog.show({
      primaryTitle: '提示',
      content: '元服务未获取phone权限或用户授权，点击确定将根据openId创建一个mock账号。',
      confirm: () => {
        this.login('')
      },
    })
  }

  public login(code: string) {
    MineServiceApi.queryAuthorInfo(encodeURIComponent(code)).then((res) => {
      this.userInfoModel.isRelative = true
      this.userInfoModel.authorNickName = res?.authorNickName ?? ''
      this.userInfoModel.authorIcon = res?.authorIcon ?? ''
      this.userInfoModel.authorPhone = res?.authorPhone ?? ''
      if (!code) {
        this.context.getPromptAction()
          .showToast({ message: '手机号绑定成功！当前手机号为mock数据，非华为账号真实手机号' });
      }
    }).catch(() => {
      this.context.getPromptAction().showToast({ message: '账号关联失败' })
    })
  }

  public cancelRelative() {
    // 创建取消授权请求，并设置参数
    const cancelRequest = new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
    cancelRequest.state = util.generateRandomUUID(); // 建议使用generateRandomUUID生成state

    // 执行取消授权请求，并处理结果
    try {
      const controller = new authentication.AuthenticationController(this.context.getHostContext());
      controller.executeRequest(cancelRequest, (error: BusinessError<Object>, data) => {
        // todo 这里可以补充关联失败异常场景，模板为了体验流程暂未处理
        UtilLog.info(TAG, 'Succeeded in canceling.');
        this.userInfoModel.isRelative = false
        this.userInfoModel.authorPhone = ''
      });
    } catch (error) {
      this.dealAllError(error);
    }
  }

  // 错误处理
  public dealAllError(error: BusinessError<Object>): void {
    UtilLog.error(TAG, `Failed to login, errorCode is ${error.code}, errorMessage is ${error.message}`);
    this.contextModel.globalUIContext.getPromptAction().showToast({ message: '账号关联失败' })
  }
}