import { AccountUtil, Logger, RouterModule, UserInfoModel } from 'commonlib';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { https } from 'network';
import { promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function bindPhoneDialogBuilder() {
  BindPhoneDialog();
}

const TAG: string = '[BindPhoneDialog]';

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

  async bindPhone(code: string) {
    try {
      const bindRes = await https.bindPhone(code);
      if (bindRes.code === 0) {
        const userInfoRes = await https.getUserInfo();
        if (userInfoRes.code === 0) {
          AccountUtil.setUserInfo(userInfoRes.data as UserInfoModel);
          Logger.info(TAG, 'succeeded in getting phone number. ');
          promptAction.showToast({ message: '手机号绑定成功！' });
          const timer = setTimeout(() => {
            this.hide();
            clearTimeout(timer);
          }, this.animateDuration);
        }
      }
    } catch (err) {
      promptAction.showToast({ message: '手机号绑定失败，请稍后重试' });
      Logger.error(TAG, 'bind phone and get user info error::' + JSON.stringify(err));
    }
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
          })
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
                  .ButtonConfig()
              },
            },
            controller: new functionalButtonComponentManager.FunctionalButtonController()
              .onGetPhoneNumber((err, data) => {
                if (err) {
                  // 错误日志处理
                  hilog.error(0x0000, 'testTag', 'error： %{public}d %{public}s', err.code, err.message);
                  return;
                }
                if (data.code) {
                  this.bindPhone(data.code);
                }
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
            })
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