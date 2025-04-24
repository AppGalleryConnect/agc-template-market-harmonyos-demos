import { BrightnessUtil, Constants, UserInfo } from 'common';
import { ServiceTitle } from './ServiceTitle';

@ComponentV2
export struct MedicalCode {
  @Local userInfo: UserInfo = AppStorage.get('userInfo') ?? new UserInfo();
  @Param title: string = ''

  aboutToAppear(): void {
    /*
     * 医保码页面调节亮度
     * */
    BrightnessUtil.setBrightness(Constants.SET_BRIGHTNESS_SLIDE)
  }

  aboutToDisappear(): void {
    BrightnessUtil.setBrightness(Constants.SET_BRIGHTNESS_CLICK)
  }

  build() {
    NavDestination() {
      ServiceTitle({
        title: '医保码',
      })
      Column({ space: Constants.CONTAINER_SPACE_TEN }) {
        Column() {
          Column({ space: Constants.CONTAINER_SPACE_TEN }) {
            Row() {
              Text($r('app.string.code_name')).fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_on_primary'))
                .fontWeight(FontWeight.Medium)
            }

            Row() {
              Text($r('app.string.card_id')).fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_on_primary'))
                .fontWeight(FontWeight.Medium)
              Text($r('app.string.insured_place')).fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_on_primary'))
                .fontWeight(FontWeight.Medium)
            }.width(Constants.FULL_PERCENT_WIDTH).justifyContent(FlexAlign.SpaceBetween)
          }
          .width(Constants.FULL_PERCENT_WIDTH)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor($r('app.color.code_color'))
          .padding($r('app.float.code_page_padding'))
          .borderRadius(Constants.RADIUS_TEN)

          Stack() {
            QRCode(JSON.stringify(this.userInfo))
              .width($r('app.float.code_qr_width'))
              .height($r('app.float.code_qr_height'))
            Image($r('app.media.logo_about'))
              .width($r('app.float.code_logo_width'))
              .height($r('app.float.code_logo_height'))
          }.margin({ top: '30%' })

          Text($r('app.string.code_description'))
            .margin({ top: $r('app.float.code_margin_top') })
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
        }
        .backgroundColor($r('sys.color.background_primary'))
        .width(Constants.FULL_PERCENT_WIDTH)
        .height(Constants.FULL_PERCENT_HEIGHT)
      }
      .backgroundColor($r('sys.color.background_primary'))
      .padding({ left: $r('app.float.code_padding'), right: $r('app.float.code_padding') })
    }
    .hideTitleBar(true)
  }
}