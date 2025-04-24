import { RouterModule } from '@ohos_agcit/office_attendance_common_lib'

@ComponentV2
export struct BlankBackground {
  hide() {
    animateTo({
      duration: 300,
      curve: Curve.Friction,
      onFinish: () => {
        RouterModule.closeDialog();
      },
    }, () => {
    });
  }

  build() {
    Column() {
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.2)')
    .opacity(1)
    .transition(
      TransitionEffect.OPACITY.animation({
        duration: 300,
        curve: Curve.Friction,
      })
    )
    .onClick(() => {
      this.hide();
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}