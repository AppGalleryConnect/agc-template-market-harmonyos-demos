import {
  commonToast,
  Constants,
  getQuickLoginAnonymousPhone,
  HomeServiceEnum,
  UserInfo,
  UserState,
} from 'common'
import { PersistenceV2 } from '@kit.ArkUI';
import { CallContentBuilder, TitleBuilder } from './CallContentBuilder';

@ComponentV2
export struct MedicalPersonCardInfo {
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @Consumer('tabCurrentIndex') tabCurrentIndex: number = 0
  @Local balance: string = '****'
  @Local balanceToggle: boolean = false
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;
  @Param isOlder: boolean = false
  @Local modelShow: boolean = false

  build() {
    Column() {
      Column() {
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          Row({ space: Constants.CONTAINER_SPACE_EIGHT }) {
            Image($r('app.media.logo_about'))
              .width(this.isOlder ? $r('app.float.person_card_logo_older') : $r('app.float.medical_card_size'))
              .height(this.isOlder ? $r('app.float.person_card_logo_older') : $r('app.float.medical_card_size'))
              .borderRadius(Constants.RADIUS_TWENTY_FOUR)
            Column({ space: Constants.CONTAINER_SPACE_EIGHT }) {
              Row() {
                Text($r('app.string.medical_security'))
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_on_secondary'))
                  .fontWeight(FontWeight.Medium)
              }.width(Constants.FULL_PERCENT_WIDTH).justifyContent(FlexAlign.Start)

              Row() {
                Text($r('app.string.medical_insurance_code'))
                  .fontSize($r('sys.float.Subtitle_L'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_on_primary'))
                Text($r('app.string.medical_insurance_voucher'))
                  .fontSize($r('sys.float.Body_S'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_on_primary'))
              }
            }
          }.width(Constants.HALF_PERCENT_WIDTH).justifyContent(FlexAlign.Start)

          Image($r('app.media.qrcode'))
            .width($r('app.float.medical_card_size'))
            .height($r('app.float.medical_card_size'))
            .onClick(() => {
              /*
              * 医保码
              * */
              if (this.userState.isLogin) {
                if (this.isOlder) {
                  this.pageInfos.pushPathByName('medicalCode', null)
                  return
                }
                this.tabCurrentIndex = HomeServiceEnum.Code
                return
              }
              commonToast.show({
                type: 'dialog',
                hasTitle: '关联账号',
                message: $r('app.string.associated_account'),
                confirmAction: () => {
                  getQuickLoginAnonymousPhone(getContext(this), (isLogin: boolean, userInfo: UserInfo) => {
                    this.userState.isLogin = isLogin
                    this.userState.userInfo = userInfo
                  })
                },
              })
            })
        }

        /*
         * 账户信息
         * */
        if (this.userState.isLogin) {
          Row({ space: Constants.CONTAINER_SPACE_FIVE }) {
            Text($r('app.string.code_name'))
              .fontColor($r('sys.color.font_on_primary'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)
            Text($r('app.string.card_id'))
              .fontColor($r('sys.color.font_on_primary'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)
          }
        } else {
          Row({ space: Constants.CONTAINER_SPACE_FIVE }) {
            Image($r('app.media.link'))
              .width($r('app.float.medical_link_size'))
              .height($r('app.float.medical_link_size'))
            Text($r('app.string.associated_account'))
              .fontColor($r('app.color.institutions_tag_bg'))
              .fontSize(Constants.FONT_SIZE_SMALL)
          }
          .backgroundColor($r('app.color.link_color'))
          .borderRadius(Constants.RADIUS_TWELVE)
          .padding($r('app.float.medical_link_padding'))
          .onClick(() => {
            getQuickLoginAnonymousPhone(getContext(this), (isLogin: boolean, userInfo: UserInfo) => {
              this.userState.isLogin = isLogin
              this.userState.userInfo = userInfo
            })
          })
        }
      }
      .height($r('app.float.medical_card_height'))
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('app.color.medical_card_bg'))
      .padding($r('app.float.medical_card_padding'))
      .margin({
        left: this.isOlder ? $r('app.float.common_margin_sixty') : 0,
        right: this.isOlder ? $r('app.float.common_margin_sixty') : 0,
      })
      .borderRadius(Constants.RADIUS_SIXTY)
      .linearGradient({
        angle: 45,
        colors: [
          ['#81A3FF', 0.0],
          ['#2F56BC', 1.0],
        ],
      })

      if (this.isOlder) {
        Row({ space: Constants.CONTAINER_SPACE_TEN }) {
          Image($r('app.media.voice_call')).width($r('app.float.call_icon_size')).height($r('app.float.call_icon_size'))
          Text($r('app.string.call_service'))
            .fontSize($r('sys.float.Title_S'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
        }
        .width($r('app.float.person_card_width'))
        .height($r('app.float.person_card_height'))
        .backgroundColor($r('app.color.person_color'))
        .padding($r('app.float.call_icon_padding'))
        .justifyContent(FlexAlign.Center)
        .borderRadius(Constants.RADIUS_TWENTY_FOUR)
        .margin({ top: $r('app.float.call_icon_margin_top'), bottom: $r('app.float.call_icon_margin_bottom') })
        .onClick(() => {
          this.modelShow = !this.modelShow
        })
      } else {
        Row() {
          Text($r('app.string.account_balance'))
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
          Row({ space: Constants.CONTAINER_SPACE_FIVE }) {
            Text(this.balanceToggle && this.userState.isLogin ? this.balance : '****')
              .fontColor($r('sys.color.font_emphasize'))
              .fontSize($r('sys.float.Body_S'))
            Image(this.balanceToggle && this.userState.isLogin ? $r('app.media.open_eye') : $r('app.media.view_eye'))
              .width($r('app.float.medical_balance_size'))
              .height($r('app.float.medical_balance_size'))
          }
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            if (this.userState.isLogin) {
              this.balance = '6424.27'
              this.balanceToggle = !this.balanceToggle
              return
            }
            /*
             * 未登录状态，提示去登录
             * */
            commonToast.show({
              type: 'dialog',
              hasTitle: '关联账号',
              message: $r('app.string.associated_account'),
              confirmAction: () => {
                getQuickLoginAnonymousPhone(getContext(this), (isLogin: boolean, userInfo: UserInfo) => {
                  this.userState.isLogin = isLogin
                  this.userState.userInfo = userInfo
                })
              },
            })
          })
        }
        .width(Constants.FULL_PERCENT_WIDTH).justifyContent(FlexAlign.SpaceBetween)
        .padding($r('app.float.medical_card_padding'))
      }
    }
    .height(this.isOlder ? $r('app.float.medical_older_content_height') : $r('app.float.medical_content_height'))
    .backgroundColor(this.isOlder ? Color.Transparent : $r('sys.color.background_primary'))
    .borderRadius(Constants.RADIUS_SIXTY)
    .width(this.isOlder ? Constants.FULL_PERCENT_WIDTH : Constants.NINETY_PERCENT_WIDTH)
    .clip(true)
    .bindSheet($$this.modelShow, CallContentBuilder(() => {
      this.modelShow = ! this.modelShow
    }), {
      height: $r('app.float.mine_sheet_height'),
      title:TitleBuilder,
      blurStyle: BlurStyle.COMPONENT_THICK,
      preferType: SheetType.BOTTOM,
    })
  }
}