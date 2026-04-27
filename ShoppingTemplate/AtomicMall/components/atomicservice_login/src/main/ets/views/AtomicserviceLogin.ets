import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../common/Constant';
import { PhoneFunctionButton } from '../components/PhoneFunctionButton';
import { CancelAuthState, UserInfo } from '../model/UserInfo';
import { ApiController } from '../utils/Utils';


@ComponentV2
export struct AtomicserviceLogin {
  @Param isLink: boolean = false
  @Require @Param userInfo: UserInfo
  @Param initValue: ResourceStr = '华为用户'
  @Param controller: ApiController = new ApiController()
  @Event bindPhone: (code: string | undefined) => void
  @Event onGetPhoneError: (err: BusinessError) => void = () => {
  };
  @Event onCancelAuthorization: (state: CancelAuthState) => void = () => {
  }
  @Event unBindPhone: () => Promise<void> = () => new Promise(() => {
  });
  @Event onClickAvatar: () => void = () => {
  }

  aboutToAppear(): void {
    this.controller.unlink = (unBindPhone: () => Promise<void>) => {
      unBindPhone()
    }
  }

  build() {
    Row() {
      Row() {
        Image(this.isLink ? this.userInfo.avatar : $r('app.media.avatar_grey'))
          .width($r('app.float.mine_avatar_width'))
          .height($r('app.float.mine_avatar_height'))
          .borderRadius($r('sys.float.corner_radius_level10'))
          .margin({ right: Constants.PADDING_L })
          .objectFit(ImageFit.Fill)
          .onClick(() => {
            if (this.isLink) {
              this.onClickAvatar?.()
            }
          })
        if (this.isLink) {
          Column({ space: Constants.SPACE_XS }) {
            Text(this.userInfo.userName || this.initValue)
              .fontSize($r('sys.float.Subtitle_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .height($r('app.float.mine_title_height'))
            Row({ space: Constants.SPACE_S }) {
              Image($r('app.media.mobile_phone'))
                .width($r('app.float.mine_phone_width'))
                .height($r('app.float.mine_phone_height'))
              Text((this.userInfo.phoneNumber ?? '').replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
                .height($r('app.float.mine_phone_height'))
            }
          }
          .alignItems(HorizontalAlign.Start)
        }
        if (!this.isLink) {
          Column() {
            Text(this.initValue)
              .fontSize($r('sys.float.Subtitle_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
          }
          .height($r('app.float.mine_avatar_height'))
          .justifyContent(FlexAlign.Center)
        }
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Top)

      if (!this.isLink) {
        Stack() {
          SymbolGlyph($r('sys.symbol.link'))
            .fontSize($r('app.float.mine_link_width'))
            .fontColor([$r('sys.color.font_primary')])
          PhoneFunctionButton({
            bindPhone: this.bindPhone,
            onGetPhoneError: this.onGetPhoneError,
          })
            .zIndex(1)
        }
        .alignContent(Alignment.Start)
        .borderRadius(Constants.BORDER_RADIUS)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .padding({
          top: Constants.PADDING_S,
          bottom: Constants.PADDING_S,
          right: Constants.PADDING_M,
          left: Constants.PADDING_M,
        })
      }
    }
    .width(Constants.FULL_PERCENT)
    .alignItems(VerticalAlign.Bottom)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
