import { ConfirmDialogOption, DialogMap, RouterModule } from 'commonlib';

@Builder
export function commonConfirmDialogBuilder() {
  CommonConfirmDialog();
}

export interface ConfirmParam {
  isConfirm: boolean;
}

@ComponentV2
export struct CommonConfirmDialog {
  @Local dialogOption: ConfirmDialogOption = {
    title: '',
    message: '',
  };
  @Local confirmParam: ConfirmParam = {
    isConfirm: false,
  };

  hide() {
    this.confirmParam.isConfirm = false;
    RouterModule.closeDialog<ConfirmParam>({
      param: this.confirmParam,
    });
  }

  confirm() {
    this.confirmParam.isConfirm = true;
    RouterModule.closeDialog<ConfirmParam>({
      param: this.confirmParam,
    });
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Text(this.dialogOption.title)
            .fontColor($r('app.color.font_color_level1'))
            .fontSize($r('app.string.font_size_20'))
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: $r('app.string.margin_m') });
          Text(this.dialogOption.message)
            .fontColor($r('app.color.font_color_level1'))
            .fontSize($r('app.string.font_size_14'))
            .margin({ bottom: $r('app.string.margin_l') });
          Row() {
            Text('取消')
              .fontSize($r('app.string.font_size_16'))
              .fontColor($r('app.color.font_color_link'))
              .onClick(() => {
                this.hide();
              });
            Text('确定')
              .fontSize($r('app.string.font_size_16'))
              .fontColor($r('app.color.font_color_link'))
              .onClick(() => {
                this.confirm();
              });
          }
          .width($r('app.string.width_percent_full'))
          .justifyContent(FlexAlign.SpaceAround)

        }
        .width($r('app.string.width_percent_full'))
        .backgroundColor($r('app.color.system_color_background_white'))
        .padding($r('app.string.padding_xl'))
        .borderRadius($r('app.string.border_radius_24'))
      }
      .padding($r('app.string.padding_l'))
      .width($r('app.string.width_percent_full'))
      .height($r('app.string.height_percent_full'));
    }
    .padding($r('app.string.padding_l'))
    .mode(NavDestinationMode.DIALOG)
    .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
    .onReady(() => {
      const param = RouterModule.getNavParam<ConfirmDialogOption>({
        url: DialogMap.COMMON_CONFIRM,
      });
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