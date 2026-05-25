import { Logger, MockService } from 'external_interactions';
import { qrCodeDialog } from './QrCodeDialog';
import { CustomContentDialog } from '@kit.ArkUI';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { LoginState ,GlobalBalance, AccountUpdate, EmitterConstant} from 'external_interactions'
import { AppStorageV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';

const TAG = '[UserInfoCard]';

@ComponentV2
export struct UserInfoCard {
  // qrCode弹窗
  @Local accountUpdateStorage : AccountUpdate = AppStorageV2.connect(AccountUpdate, 'AccountUpdate', () =>new AccountUpdate())!
  @Local globalBalanceStorage : GlobalBalance = AppStorageV2.connect(GlobalBalance, 'GlobalBalance', () =>new GlobalBalance())!
  @Local loginStateStorage : LoginState = AppStorageV2.connect(LoginState, 'LoginState', () =>new LoginState())!
  private qrCodeDialogController?: CustomDialogController;
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  @Local loginState: boolean = this.loginStateStorage.loginState;
  @Local cardNumber: string = '';
  @Local nickname: string = '';
  @Local avatar: ResourceStr = '';
  @Local balance: number = this.globalBalanceStorage.globalBalance;
  @Local accountUpdate: boolean = this.accountUpdateStorage.accountUpdate;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '账号解除关联',
      contentBuilder: () => {
        this.buildContent();
      },
      buttons: [
        {
          value: '取消',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
          }
        },
        {
          value: '确定',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            this.loginStateStorage.loginState = false
            MockService.dataPreferences.putSync('loginState', false)
            MockService.dataPreferences.flush()
            this.refreshUserInfo();
          }
        }
      ],
    }),
  });

  @Builder
  buildContent() {
    Text('请确认是否解除账号关联')
      .width('100%')
      .textAlign(TextAlign.Center)
      .fontSize(14)
  }

  @Monitor('accountUpdateStorage')
  refreshUserInfo() {
    if (this.loginStateStorage.loginState) {
      this.cardNumber = MockService.account.memberId
      this.globalBalanceStorage.globalBalance = MockService.account.balance
      this.nickname = MockService.account.nickname
      this.avatar = MockService.account.avatar
    }
  }

  aboutToAppear(): void {
    try {
      emitter.on(EmitterConstant.CANCEL_BOOK, () => {
        this.refreshUserInfo()
      })
    } catch (e) {
      Logger.error(TAG, `emitter on failed. error: ${JSON.stringify(e)}`)
    }
    this.refreshUserInfo();
  }

  aboutToDisappear(): void {
    try {
      emitter.off(EmitterConstant.CANCEL_BOOK)
    } catch (e) {
      Logger.error(TAG, `emitter off failed. error: ${JSON.stringify(e)}`)
    }
  }

  build() {
    Column() {
      Row() {
        Row() {
          Row() {
            Image(this.loginStateStorage.loginState ? (this.avatar ? this.avatar : $r('app.media.avatar_no_login')) :
            $r('app.media.avatar_no_login'))
              .width(72)
              .height(72)
              .borderRadius(36)
            Row() {
              Image($r('app.media.associate_avator'))
                .width(12)
                .height(12)
              Text(this.loginStateStorage.loginState ? '解除关联' : '关联账号')
                .fontSize(10)
                .fontColor(Color.White)
                .margin({ left: 5 })
            }
            .justifyContent(FlexAlign.Center)
            .width(72)
            .height(24)
            .borderRadius(12)
            .backgroundColor('#FF9019')
            .margin({ left: 12 })
            .onClick(() => {
              if (this.loginStateStorage.loginState) {
                this.dialogController.open()
              } else {
                this.cancelAuthorization()
              }
            })
          }
          .onClick(() => {
            if (this.loginStateStorage.loginState) {
              if (this.pathStack) {
                this.pathStack.pushPath({ name: 'vip/MineInfoPage', param: this.loginState })
              }
            }
          })

          Column() {
            if (this.loginStateStorage.loginState) {
              Row() {
                Image($r('app.media.qr_icon'))
                  .width(24)
                  .height(24)
              }
              .alignItems(VerticalAlign.Top)
              .justifyContent(FlexAlign.Center)
              .margin({ bottom: 4 })
            }

            Text(this.loginStateStorage.loginState ? '会员码' : '无会员码')
              .fontSize(12)
              .fontColor($r('sys.color.comp_background_list_card'))
          }
          .onClick(() => {
            if (this.loginStateStorage.loginState) {
              this.pathStack.pushPath({name: 'userInfo/qrCode'})
            }
          })
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1)
      }

      Row() {
        Text('卡号：' + (this.loginStateStorage.loginState ? this.cardNumber : '无'))
          .fontSize(12)
          .fontColor($r('sys.color.comp_background_list_card'))

        Text('余额：' + (this.loginStateStorage.loginState ? this.globalBalanceStorage.globalBalance : '无'))
          .fontSize(12)
          .fontColor($r('sys.color.comp_background_list_card'))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .margin({ top: 15 })
    }
    .width('100%')
    .backgroundImage($r('app.media.user_card_background'))
    .backgroundImageSize({ width: '100%', height: '100%' })
    .borderRadius(16)
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 20
    })
  }

  /**
   * 创建删除提示弹框的Controller
   */
  private openQrCodeConfirmDialog(): void {
    qrCodeDialog({ pathStack: this.pathStack })
  }

  private getPhone() {
    const authRequest: authentication.AuthorizationWithHuaweiIDRequest =
      new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    authRequest.scopes = ['phone'];
    authRequest.permissions = ['serviceauthcode'];
    authRequest.forceAuthorization = true;
    authRequest.state = util.generateRandomUUID();
    try {
      const controller: authentication.AuthenticationController =
        new authentication.AuthenticationController(this.getUIContext().getHostContext());
      controller.executeRequest(authRequest)
        .then((data: authentication.AuthenticationResponse) => {
          const authorizationWithHuaweiIDResponse = data as authentication.AuthorizationWithHuaweiIDResponse;
          const state: string = authorizationWithHuaweiIDResponse.state!;
          if (state && authRequest.state !== state) {
            return;
          }
          this.updateLogin()
        })
        .catch(() => {
          // Mock逻辑，不管是否有证书权限，都直接关联
          this.updateLogin()
        })
    } catch (error) {
      // Mock逻辑，不管是否有证书权限，都直接关联
      this.updateLogin()
      Logger.error(TAG, `Failed to authorize. errCode: ${error.code}, errMessage: ${error.message}`);
    }
  }

  cancelAuthorization() {
    const cancelRequest: authentication.CancelAuthorizationRequest =
      new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
    cancelRequest.state = util.generateRandomUUID();
    try {
      const controller: authentication.AuthenticationController = new authentication.AuthenticationController();
      controller.executeRequest(cancelRequest)
        .then((data: authentication.AuthenticationResponse) => {
          let cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
          let state: string = cancelAuthorizationResponse.state!;
          if (cancelRequest.state !== state) {
            Logger.error(TAG, 'Failed to cancel. The state is different');
            return;
          }
          this.getPhone()
        })
        .catch((err: BusinessError) => {
          this.getPhone()
          Logger.error(TAG, `Failed to authorize. errCode: ${err.code}, errMessage: ${err.message}`);
        })
    } catch (err) {
      this.getPhone()
      Logger.error(TAG, `Failed to authorize. errCode: ${err.code}, errMessage: ${err.message}`);
    }
  }

  updateLogin() {
    this.loginStateStorage.loginState = true
    MockService.dataPreferences.putSync('loginState', true)
    MockService.dataPreferences.flush()
    this.refreshUserInfo();
  }
}