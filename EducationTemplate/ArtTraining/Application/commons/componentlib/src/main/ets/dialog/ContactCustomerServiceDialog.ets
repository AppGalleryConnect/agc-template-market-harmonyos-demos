import { DialogMap, RouterModule, TelUtil } from 'commonlib';

@Builder
export function contactCustomerServiceBuilder() {
  ContactCustomerServiceDialog();
}

@ComponentV2
export struct ContactCustomerServiceDialog {
  @Local phoneNum: string = '';

  hide() {
    RouterModule.pop();
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          Row()
            .width(48)
            .height(4)
            .backgroundColor($r('app.color.icon_color_level4'))
            .margin({ top: $r('app.string.margin_s'), bottom: $r('app.string.margin_m') });
          Row() {
            Text('联系客服')
              .fontSize($r('app.string.font_size_20'))
              .fontColor($r('app.color.font_color_level1'))
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1);
            Image($r('app.media.ic_close'))
              .width($r('app.integer.icon_size_32'))
              .onClick(()=> {
                this.hide();
              })
          }
          .width($r('app.string.width_percent_full'))
          .margin({ bottom: $r('app.string.margin_m') });

          Column() {
            Text(this.phoneNum)
              .fontColor($r('app.color.font_color_level1'))
              .fontSize($r('app.string.font_size_20'))
              .fontWeight(FontWeight.Medium)
              .margin({ top: $r('app.string.margin_m'), bottom: $r('app.string.margin_xl') });

            Button() {
              Row() {
                Image($r('app.media.ic_tel_filled'))
                  .width($r('app.integer.icon_size_24'))
                  .margin({ right: $r('app.string.margin_m') });
                Text('一键拨号')
                  .fontColor($r('app.color.font_color_level1_invert'))
                  .fontWeight(FontWeight.Medium);
              };
            }
            .width($r('app.string.width_percent_full'))
            .height(40)
            .backgroundColor($r('app.color.system_theme_color'))
            .margin({ bottom: $r('app.string.margin_m') })
            .onClick(() => {
              TelUtil.makeCall(this.phoneNum);
              this.hide();
            });

            Button('取消')
              .backgroundColor($r('app.color.system_color_background_grey_level2'))
              .fontColor($r('app.color.font_color_level2'))
              .fontWeight(FontWeight.Medium)
              .height(40)
              .width($r('app.string.width_percent_full'))
              .onClick(() => {
                this.hide();
              });

          }
          .backgroundColor($r('app.color.system_color_background_white'))
          .width($r('app.string.width_percent_full'))
          .padding($r('app.string.padding_xl'))
          .borderRadius({
            topLeft: $r('app.string.border_radius_16'),
            topRight: $r('app.string.border_radius_16'),
          })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])


        }
        .width($r('app.string.width_percent_full'))
        .backgroundColor($r('app.color.system_color_background_auxiliary'))
        .padding({
          left: $r('app.string.padding_l'),
          right: $r('app.string.padding_l'),
        })
        .borderRadius({
          topLeft: $r('app.string.border_radius_32'),
          topRight: $r('app.string.border_radius_32'),
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
      .width($r('app.string.width_percent_full'))
      .height($r('app.string.height_percent_full'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .mode(NavDestinationMode.DIALOG)
    .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
    .onReady(() => {
      const param = RouterModule.getNavParam<string>({
        url: DialogMap.CONTACT_CUSTOM_SERVICE,
      });
      if (param) {
        this.phoneNum = param;
      }
    })
    .onBackPressed(() => {
      return false;
    })
    .backgroundColor('rgba(0, 0, 0, 0.3)')
    // .systemTransition(NavigationSystemTransitionType.NONE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);
  }
}