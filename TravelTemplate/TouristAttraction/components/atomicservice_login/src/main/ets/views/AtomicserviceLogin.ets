import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../common/Constant';
import { PhoneFunctionButton } from '../components/PhoneFunctionButton';
import { CancelAuthState, UserInfo } from '../model/UserInfo';
import { AccountUtils } from '../utils/AccountUtils';
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
  @Event linkToEdit: () => void = () => {
  }

  aboutToAppear(): void {
    this.controller.unlink = (unBindPhone: () => Promise<void>) => {
      this.getUIContext().showAlertDialog({
        title: '账号解除关联',
        message: '请确认是否解除账号关联？',
        buttons: [{
          value: '取消',
          action: () => {
          },
        }, {
          value: '确认',
          action: () => {
            AccountUtils.cancelRelative(this.onCancelAuthorization)
            unBindPhone()
          },
        }],
      })
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
        if (this.isLink) {
          Column({ space: Constants.SPACE_XS }) {
            Text(this.userInfo.nickname || this.initValue)
              .fontSize($r('sys.float.Subtitle_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .height($r('app.float.mine_title_height'))
            Row({ space: Constants.SPACE_S }) {
              Image($r('app.media.mobile_phone'))
                .width($r('app.float.mine_phone_width'))
                .height($r('app.float.mine_phone_height'))
              Text((this.userInfo.phone ?? '').replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
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
      .onClick(() => {
        if (this.isLink) {
          this.linkToEdit()
        }
      })

      if (this.isLink) {
        Button() {
          Row({ space: Constants.SPACE_XS }) {
            SymbolGlyph($r('sys.symbol.link_slash'))
              .fontColor([$r('sys.color.font_on_primary')])
              .fontSize($r('app.float.mine_link_width'))
            Text('取消关联')
              .fontColor($r('sys.color.font_on_primary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
          }
        }
        .controlSize(ControlSize.SMALL)
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .padding({
          top: Constants.PADDING_XXS,
          bottom: Constants.PADDING_XXS,
          right: Constants.PADDING_S,
          left: Constants.PADDING_S,
        })
        .onClick(() => {
          this.controller.unlink(this.unBindPhone)
        })
      }
      if (!this.isLink) {
        Stack() {
          SymbolGlyph($r('sys.symbol.link'))
            .fontSize($r('app.float.mine_link_width'))
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
          top: Constants.PADDING_XXS,
          bottom: Constants.PADDING_XXS,
          right: Constants.PADDING_S,
          left: Constants.PADDING_S,
        })
      }
    }
    .width(Constants.FULL_PERCENT)
    .padding(Constants.PADDING_M)
    .alignItems(VerticalAlign.Bottom)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
