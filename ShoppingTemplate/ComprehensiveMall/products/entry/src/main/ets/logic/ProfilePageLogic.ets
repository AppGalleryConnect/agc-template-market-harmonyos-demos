import { iData } from '@common/data';
import { client } from '@common/network';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';


@ObservedV2
export class ProfilePageLogic {
  public readonly onLoginButtonStart = async (needWaitFinish: boolean): Promise<void> => {
    if (!needWaitFinish && iData.global.isLogin) {
      client.user.logout(iData.local.userToken);
      this.cancelAuthorization();
      iData.local.userToken = '';
      iData.global.isLogin = false;
      iData.global.nickname = '';
      iData.global.phone = '';
      iData.global.avatar = '';
      iData.global.cartVersion = '';
      iData.global.cartTotal = 0;
    }
  };
  public cancelAuthorization = async () => {
    const cancelRequest: authentication.CancelAuthorizationRequest =
      new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
    cancelRequest.state = util.generateRandomUUID();
    try {
      const controller: authentication.AuthenticationController = new authentication.AuthenticationController();
      controller.executeRequest(cancelRequest).then((data: authentication.AuthenticationResponse) => {
        const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
        const state: string = cancelAuthorizationResponse.state!;
        if (cancelRequest.state !== state) {
          console.error('Failed to cancel. The state is different');
          return;
        }
        promptAction.showToast({ message: '解除账号关联成功！' });
        console.debug('cancel authorization success');
      }).catch((err: BusinessError) => {
        console.error(`Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
      });
    } catch (err) {
      console.error(`Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
    }
  };
}
