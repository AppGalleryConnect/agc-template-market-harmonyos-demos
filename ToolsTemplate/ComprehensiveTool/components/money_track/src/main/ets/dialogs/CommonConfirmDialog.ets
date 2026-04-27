import { ConfirmDialogOption } from '../commons/Types';

@Builder
export function commonConfirmDialogBuilder() {
  CommonConfirmDialog();
}

export interface ConfirmParam {
  isConfirm: boolean;
}

@ComponentV2
export struct CommonConfirmDialog {
  @Local
  stack: NavPathStack = new NavPathStack()
  @Local dialogOption: ConfirmDialogOption = {
    title: '',
    message: '',
  };
  @Local confirmParam: ConfirmParam = {
    isConfirm: false,
  };

  hide() {
    this.confirmParam.isConfirm = false;
    this.stack.pop({
      param: this.confirmParam,
    });
  }

  confirm() {
    this.confirmParam.isConfirm = true;
    this.stack.pop({
      param: this.confirmParam,
    });
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          if (this.dialogOption.title) {
            Text(this.dialogOption.title)
              .fontColor($r('app.color.font_color_level1'))
              .fontSize($r('app.string.font_size_20'))
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: $r('app.string.space_m') });
          }
          Text(this.dialogOption.message)
            .fontColor($r('app.color.font_color_level1'))
            .fontSize($r('app.string.font_size_16'))
            .margin({ bottom: $r('app.string.space_xl') });
          Row() {
            Text('取消')
              .fontSize($r('app.string.font_size_16'))
              .fontColor($r('app.color.font_color_level1'))
              .onClick(() => {
                this.hide();
              });
            Text('确定')
              .fontSize($r('app.string.font_size_16'))
              .fontColor($r('app.color.icon_color_warning'))
              .onClick(() => {
                this.confirm();
              });
          }
          .width($r('app.string.width_percent_full'))
          .justifyContent(FlexAlign.SpaceAround)

        }
        .width($r('app.string.width_percent_full'))
        .backgroundColor($r('app.color.system_color_background_white'))
        .padding($r('app.string.space_xl'))
        .borderRadius($r('app.string.border_radius_24'))
      }
      .padding($r('app.string.space_l'))
      .width($r('app.string.width_percent_full'))
      .height($r('app.string.height_percent_full'));
    }
    .padding($r('app.string.space_l'))
    .mode(NavDestinationMode.DIALOG)
    .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
    .onReady((context) => {
      this.stack = context.pathStack;
      const param = context.pathInfo.param as ConfirmDialogOption
      if (param) {
        this.dialogOption = param;
      }
    })
    .onBackPressed(() => {
      return false;
    })
    .backgroundColor('rgba(0, 0, 0, 0.3)')
    .systemTransition(NavigationSystemTransitionType.NONE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);
  }
}