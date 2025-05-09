import util from '@ohos.util';
import { BusinessError } from '@ohos.base';
import { FunctionalButton, functionalButtonComponentManager } from '@hms.core.atomicserviceComponent.atomicserviceUi';

import { client } from '@common/network';
import { iData } from '@common/data';
import { CartDto, UserDto } from '@common/customtypes';

@ComponentV2
export struct LoginButton {

  private uuid: string = util.generateRandomUUID(false);

  @Local
  private isLoading: boolean = false;

  @Event
  public onStart: (needWaitFinish: boolean) => void = () => {};

  @Event
  public onFinish: () => void = () => {};

  @BuilderParam
  public contentBuilder: () => void = buildEmptyComponent;

  build(): void {
    RelativeContainer() {
      Column() {
        this.contentBuilder()
      }
      .id(this.uuid)
      .onClick(() => {
        if (iData.global.isLogin) {
          this.onStart(false);   // 按钮被点击时，已经处于登录状态
        } else {
          this.isLoading = true; // 进入加载状态，拉起透明全模态页面，防止按钮被重复点击，防止页面其它元素被点击，屏蔽左滑返回
          this.onStart(true);    // 按钮被点击时，尚未处于登录状态，需要等待登录结果，即等待 onFinish 回调
        }
      })
      Column() {
        if (!iData.global.isLogin) {
          FunctionalButton({
            params: {
              openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
              label: '',
              styleOption: {
                styleConfig: new functionalButtonComponentManager.ButtonConfig()
                  .width('100%')
                  .height('100%')
                  .borderRadius(0)
                  .backgroundColor(Color.Transparent)
                  .stateEffect(false)
              }
            },
            controller: new functionalButtonComponentManager.FunctionalButtonController()
              .onGetPhoneNumber((
                error: BusinessError<void>,
                data: functionalButtonComponentManager.GetPhoneNumberResult
              ) => {
                if (!error && data.code) {
                  client.user.loginByCode(data.code)
                    .then((user: UserDto) => {
                      iData.local.userToken = user.token;
                      iData.global.isLogin = true;
                      iData.global.nickname = user.nickname;
                      iData.global.phone = user.maskedPhoneNumber;
                      client.cart.getCartData().then((cartDto: CartDto) => {
                        iData.global.cartVersion = cartDto.version;
                        iData.global.cartTotal = cartDto.total;
                      });
                    })
                    .finally(() => {
                      this.isLoading = false;
                      this.onFinish();
                    })
                } else {
                  this.isLoading = false;
                  this.onFinish();
                }
              })
          })
        }
      }
      .alignRules({
        left: { anchor: this.uuid, align: HorizontalAlign.Start },
        right: { anchor: this.uuid, align: HorizontalAlign.End },
        top: { anchor: this.uuid, align: VerticalAlign.Top },
        bottom: { anchor: this.uuid, align: VerticalAlign.Bottom }
      })
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .width('auto')
    .height('auto')
    .bindContentCover(this.isLoading, buildBlockComponent(), {
      modalTransition: ModalTransition.NONE,
      onWillDismiss: () => {}
    })
  }
}

@Builder
function buildBlockComponent() {
  Column()
    .width('100%')
    .height('100%')
}

@Builder
function buildEmptyComponent() {
  // No need to do anything
}
