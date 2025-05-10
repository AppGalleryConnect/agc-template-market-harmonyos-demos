import {
  AvatarFunctionButton,
  cancelRelative,
  commonToast,
  NavigationTitle,
  TextStyleModifier,
  UserInfo,
  UserState
} from 'common'
import { PersistenceV2, promptAction } from '@kit.ArkUI';

@Builder
export function PersonInformationBuilder() {
  PersonInformation()
}


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
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .border({
      width: { bottom: 1 },
      color: '#f5f5f5',
    })
  }

  aboutToAppear(): void {
    this.nickName = this.userState.userInfo.userName
  }

  build() {
    NavDestination() {
      NavigationTitle({
        title: '个人信息'
      })
      Column() {
        Column() {
          Row() {
            Text('头像')
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Row() {
              AvatarFunctionButton({
                avatarSize: 40,
              })
              Image($r('app.media.chevron_right')).width(12).height(24)
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
              Text('昵称').fontSize($r('sys.float.Body_M'))
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
                      this.userState.userInfo.userName = value
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
              Text('电话').attributeModifier(new TextStyleModifier('font_primary/Body_M/Medium'))
              Row() {
                Text(this.userState.userInfo.phoneNumber.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
                  .attributeModifier(new TextStyleModifier('font_secondary/Body_M/Regular'))
              }
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .alignItems(VerticalAlign.Center)
            .padding({ top: 12, bottom: 12 })
          }
          .padding({ left: 16, right: 16 })
          .borderRadius(16)
          .backgroundColor($r('sys.color.background_primary'))
        }

        Button('退出登录')
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor('#C4272B')
          .width('80%')
          .onClick(() => {
            commonToast.show({
              type: 'dialog',
              hasTitle: '退出登录',
              message: $r('app.string.sure_release'),
              confirmAction: () => {
                this.userState.isLogin = false
                this.userState.userInfo = new UserInfo()
                commonToast.hide()
                this.pageInfos.pop()
              },
            })
          })
          .margin({ bottom: 20 })
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({
        left: 16,
        right: 16,
      })
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_primary'))
  }
}