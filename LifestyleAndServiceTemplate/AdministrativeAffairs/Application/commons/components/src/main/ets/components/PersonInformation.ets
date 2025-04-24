import { Constants, UserState } from 'common'
import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { AvatarFunctionButton } from './AvatarFunctionButton';

@ComponentV2
export struct PersonInformation {
  @Param title: string = ''
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;
  @Local isEdit: boolean = false
  @Local nickName: string = this.userState.userInfo.userName
  @Local avatar: string = this.userState.userInfo.userName
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  @Styles
  infoFancyStyle() {
    .width(Constants.FULL_PERCENT_WIDTH)
    .padding({ top: $r('app.float.person_card_padding'), bottom: $r('app.float.person_card_padding') })
    .border({
      width: { bottom: 1 },
      color: $r('app.color.person_card_bg'),
    })
  }

  aboutToAppear(): void {
    this.nickName = this.userState.userInfo.userName
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            Text($r('app.string.avatar'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Row() {
              AvatarFunctionButton({
                avatarSize: 40,
              })
              Image($r('app.media.icon_Right')).width(24).height(24)
            }
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .infoFancyStyle()
          .backgroundColor($r('sys.color.background_primary'))
          .margin({ bottom: 12, top: 12 })
          .padding(12)
          .borderRadius(16)

          Column() {
            Row() {
              Text($r('app.string.name')).fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
              Row() {
                if (this.isEdit) {
                  TextInput({ text: this.nickName })
                    .showUnderline(true)
                    .width('40%')
                    .fontSize($r('sys.float.Body_M'))
                    .key('nickName_input')
                    .onChange((value) => {
                      this.nickName = value
                    })
                    .onBlur(() => {
                      this.isEdit = false
                    })
                } else {
                  Text(this.nickName).fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_secondary'))
                }
                Image($r('app.media.icon_brush')).width(24).height(24)
                  .onClick(() => {
                    this.isEdit = !this.isEdit
                    setTimeout(() => {
                      focusControl.requestFocus('nickName_input');
                    }, 300)
                  })
              }
            }.justifyContent(FlexAlign.SpaceBetween).infoFancyStyle()

            Row() {
              Text($r('app.string.phone_number')).fontSize(Constants.FONT_SIZE_SMALL).fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
              Row() {
                Text(this.userState.userInfo.phoneNumber.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))
                Image($r('app.media.icon_Right')).width(24).height(24)
              }
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width(Constants.FULL_PERCENT_WIDTH)
            .alignItems(VerticalAlign.Center)
            .padding({ top: $r('app.float.person_card_padding'), bottom: $r('app.float.person_card_padding') })
          }
          .padding({ left: 16, right: 16 })
          .borderRadius(16)
          .backgroundColor($r('sys.color.background_primary'))
        }

        Button('保存')
          .backgroundColor($r('sys.color.background_emphasize'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .width('80%')
          .onClick(() => {
            this.userState.userInfo.userName = this.nickName
            this.pageInfos.pop()
            promptAction.showToast({ message: '信息修改成功！' })
          })
          .margin({ bottom: Number(AppStorage.get('bottomRectHeight')) + 20 })
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({
        left: $r('app.float.common_margin_sixty'),
        right: $r('app.float.common_margin_sixty'),
      })
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .title(this.title)
    .backgroundColor($r('sys.color.background_primary'))
    .padding({
      top: Number(AppStorage.get('topRectHeight')),
    })
  }
}