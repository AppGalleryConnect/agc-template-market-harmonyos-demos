import { ComponentConst } from 'componentlib';

@ComponentV2
export struct ClassSignInButton {
  build() {
    RelativeContainer() {
      Image($r('app.media.ic_calendar'))
        .width(80)
        .height(ComponentConst.FULL_PARENT)
        .alignRules({ left: ComponentConst.bindStart() })
        .margin({
          left: $r('app.string.margin_xm'),
          top: $r('app.string.margin_xs'),
          bottom: $r('app.string.margin_xs'),
        })
        .id('sign_in_calendar')

      Text($r('app.string.home_class_sign_in'))
        .fontColor(Color.White)
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: ComponentConst.bindVerticalCenter(),
          middle: ComponentConst.bindHorizontalCenter(),
        })
        .id('sign_in_title')

      Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
        Image($r('app.media.ic_arrow_right'))
          .width('50%')
          .height('50%')
      }
      .alignRules({
        end: ComponentConst.bindEnd(),
        bottom: ComponentConst.bindBottom(),
      })
      .margin({
        right: $r('app.string.margin_xm'),
        bottom: $r('app.string.margin_xm'),
      })
      .backgroundColor(Color.White)
      .width(40)
      .height(40)
      .borderRadius(20)
      .id('sign_in_btn_icon')
    }
    .linearGradient({
      direction: GradientDirection.Right,
      colors: [
        [$r('app.color.system_color_focus'), 0.0],
        [$r('sys.color.multi_color_09'), 1.0],
      ],
    })
    .borderRadius(ComponentConst.CARD_RADIUS_MIDDLE)
    .shadow({
      radius: $r('app.string.shadow_xs'),
      offsetX: 2,
      offsetY: 4,
    })
    .width(ComponentConst.FULL_PARENT)
    .height(96)
  }
}