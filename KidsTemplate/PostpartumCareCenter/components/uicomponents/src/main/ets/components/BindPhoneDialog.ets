import { AccountUtil, Logger, RouterModule } from '@ohos_agcit/postpartum_care_center_utils';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { promptAction } from '@kit.ArkUI';

@Builder
export function bindPhoneDialogBuilder() {
  BindPhoneDialog();
}

const TAG: string = '[testTagBindPhoneDialog]';

@ComponentV2
export struct BindPhoneDialog {
  @Local heightSize: string = '50%';
  @Local opacityNum: number = 1;
  @Local animateDuration: number = 300;

  hide() {
    animateTo({
      duration: this.animateDuration,
      curve: Curve.Friction,
      onFinish: () => {
        RouterModule.closeDialog();
      },
    }, () => {
      this.heightSize = '0%';
      this.opacityNum = 0;
    });
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.3)')
        .opacity(this.opacityNum)
        .transition(
          TransitionEffect.OPACITY.animation({
            duration: this.animateDuration,
            curve: Curve.Friction,
          }),
        )
        .onClick(() => {
          this.hide();
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);

        Column() {
          FunctionalButton({
            params: {
              openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
              label: '快速验证手机号',
              styleOption: {
                plain: true,
                styleConfig: new functionalButtonComponentManager
                  .ButtonConfig(),
              },
            },
            controller: new functionalButtonComponentManager.FunctionalButtonController()
              .onGetPhoneNumber((err, data) => {
                if (err) {
                  Logger.error(TAG, 'onGetPhoneNumber err::' + JSON.stringify(err));
                } else {
                  if (data.code) {
                    AccountUtil.setUserInfo({isLogin: true, phone: '12345678910', nickname: '瓜瓜', avatar: 'app.media.ic_user_pic' });
                    Logger.info(TAG, 'succeeded in getting phone number. ');
                    promptAction.showToast({ message: '手机号绑定成功' });
                  }
                }
                const timer = setTimeout(() => {
                  this.hide();
                  clearTimeout(timer);
                }, this.animateDuration);
              }),
          }).margin('16vp');
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius({
          topLeft: '16vp',
          topRight: '16vp',
        })
        .height(this.heightSize)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .transition(
          TransitionEffect.move(TransitionEdge.BOTTOM)
            .animation({
              duration: this.animateDuration,
              curve: Curve.Friction,
            }),
        );
      }
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }
    .mode(NavDestinationMode.DIALOG)
    .onBackPressed(() => {
      return false;
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);
  }
}