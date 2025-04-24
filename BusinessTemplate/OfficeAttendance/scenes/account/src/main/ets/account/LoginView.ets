import { Logger, WindowUtil } from '@ohos_agcit/office_attendance_common_lib';
import { BaseResponse } from '@ohos_agcit/office_attendance_network';
import { RequestProxy } from '../api/RequestProxy';
import { promptAction } from '@kit.ArkUI';

const TAG: string = '[AccountBindingView]';

@ComponentV2
export struct LoginView {
  @Local checkInComponentHeight: number | string = '100%'
  @Local isChecking: boolean = true;
  @Local account: string = '';
  @Local password: string = '';
  @Param callback: () => void = () => {
  };

  build() {
    Scroll() {
      Stack() {
        Column() {
          Image($r('app.media.startIcon')).height(72).width(72).borderRadius(16).margin({ top: 154 })
          TextInput({ placeholder: $r('app.string.login_tip_account') })
            .backgroundColor(Color.Transparent)
            .width('100%')
            .height(56)
            .fontSize(16)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('app.string.black_60'))
            .onChange((value: string) => {
              this.account = value;
            })
            .margin({ top: 40 })
            .textAlign(TextAlign.Start)

          Divider().strokeWidth(1).color($r('app.string.black_20'))

          TextInput({ placeholder: $r('app.string.login_tip_password') })
            .backgroundColor(Color.Transparent)
            .type(InputType.Password)
            .width('100%')
            .height(56)
            .fontSize(16)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('app.string.black_60'))
            .onChange((value: string) => {
              this.password = value;
            })
            .margin({ top: 10 })
            .textAlign(TextAlign.Start)

          Divider().strokeWidth(1).color($r('app.string.black_20'))

          Button($r('app.string.login'))
            .width('100%')
            .height(40)
            .border({ radius: 20 })
            .fontColor(Color.White)
            .backgroundColor($r('app.color.account_binding_button'))
            .fontSize(16)
            .margin({ top: 32 })
            .onClick(() => {
              if (this.account === '') {
                promptAction.showToast({ message: $r('app.string.account_can_not_empty'), duration: 2000 });
              } else if (this.password === '') {
                promptAction.showToast({ message: $r('app.string.password_can_not_empty'), duration: 2000 })
              } else {
                RequestProxy.login().then((resp: BaseResponse<undefined>) => {
                  this.callback();
                });
              }
            })
        }.width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)

        if (this.isChecking) {
          Row() {
            LoadingProgress().width(80).height(80)
          }
          .width('100%')
          .height(this.checkInComponentHeight)
          .backgroundColor(Color.White)
          .align(Alignment.Center)
          .justifyContent(FlexAlign.Center)
        }
      }
      .margin({ left: 28, right: 28 })
    }.height(this.checkInComponentHeight).scrollBar(BarState.Off).onAreaChange((oldValue, newValue) => {
      this.calculateScrollAreaHeight()
    })
  }

  async aboutToAppear(): Promise<void> {
    RequestProxy.isLoggedIn().then((resp: BaseResponse<boolean>) => {
      this.isChecking = false;
      Logger.info(TAG, 'account bound is: ' + resp.data)
      if (resp.data) {
        this.callback(); // 如果已经绑定直接跳转
      }
    })
  }

  private calculateScrollAreaHeight() {
    const height = WindowUtil.getInstance()?.getAppStorageData().windowHeightVp as number;
    if (height > 666) { // 如何实际显示内容区域高于高保真设计的高度666，则按百分之百显示，否则按高保真高度显示
      this.checkInComponentHeight = '100%'
      return;
    }

    this.checkInComponentHeight = 666;
  }
}