import { Constants, HotService } from 'common';
import { HotServiceCard } from 'components';

@ComponentV2
export struct HotServices {
  @Param hotServices: HotService[] = [];

  aboutToAppear(): void {
  }

  @Builder
  hotServiceHeader() {
    Row({ space: Constants.CONTAINER_SPACE_TEN }) {
      Row()
        .width($r('app.float.hot_line_icon_width'))
        .height($r('app.float.hot_line_icon_height'))
        .backgroundColor($r('app.color.hot_service_bg'))
      Text($r('app.string.hot_service')).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .justifyContent(FlexAlign.Start)
    .margin({ bottom: $r('app.float.hot_header_margin'), left: $r('app.float.common_margin_twelve') })
  }

  build() {
    Column() {
      this.hotServiceHeader()
      HotServiceCard({
        hotServices: this.hotServices,
      })

    }
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ top: $r('app.float.hot_service_margin'), left: $r('app.float.common_margin_sixty'), right: $r('app.float.common_margin_sixty') })
    .borderRadius(Constants.RADIUS_SIXTY)
    .padding({
      left: $r('app.float.common_padding_twelve'),
      top: $r('app.float.common_padding_sixty'),
      bottom: $r('app.float.common_padding_sixty'),
      right: $r('app.float.common_padding_twelve'),
    })
  }
}
