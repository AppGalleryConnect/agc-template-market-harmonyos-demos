import { choosePhoto, commonToast, UserInfo } from 'common'
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct PersonInformation {
  @StorageLink('userInfo') userInfo: UserInfo = AppStorage.get('userInfo') ?? new UserInfo();
  @StorageLink('isLogin') isLogin: boolean = false
  @State isEdit: boolean = false
  @State nickName: string = this.userInfo.userName
  @State avatar: string = this.userInfo.userName
  @Consume('pageInfos') pageInfos: NavPathStack

  @Styles
  infoFancyStyle() {
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .border({
      width: { bottom: 1 },
      color: $r('app.color.person_card_bg'),
    })
  }

  @Builder
  titleBuilder() {
    Column() {
      Text('个人信息')
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
    }
    .justifyContent(FlexAlign.Center)
    .margin({ left: 8 })
    .height('100%')
  }

  aboutToAppear(): void {
    this.nickName = this.userInfo.userName
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            Text($r('app.string.avatar'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Row() {
              Row() {
                Image(this.userInfo.avatar || $r('app.media.avatar_grey')).width(40).height(40)
              }
              .borderRadius('50%')
              .clip(true)

              Image($r('app.media.icon_Right')).width(24).height(24)
            }
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .infoFancyStyle()
          .backgroundColor($r('sys.color.background_primary'))
          .margin({ bottom: 12, top: 12 })
          .padding(12)
          .borderRadius(16)
          .onClick(async () => {
            let uri = await choosePhoto()
            // 成功日志处理
            let file: fs.File = null!;
            try {
              file = fs.openSync(uri, fs.OpenMode.READ_ONLY)
              this.userInfo.avatar = `${util.generateRandomUUID(false)}.jpg`

              let imagePath = `${getContext().filesDir}/${this.userInfo.avatar}`
              fs.copyFileSync(file.fd, imagePath)
              this.userInfo.avatar = 'file://' + imagePath
            } catch (error) {
              let err: BusinessError = error as BusinessError;
              console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
            } finally {
              fs.closeSync(file);
            }
          })

          Column() {
            Row() {
              Text($r('app.string.name')).fontSize($r('sys.float.Body_L'))
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
                      this.userInfo.userName = value
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
              Text($r('app.string.phone_number')).fontSize(14).fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
              Row() {
                Text(this.userInfo.phoneNumber && this.userInfo.phoneNumber.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))
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
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({
        left: 16,
        right: 16,
      })
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .title(this.titleBuilder)
    .backgroundColor($r('sys.color.background_primary'))
    .padding({
      top: Number(AppStorage.get('topRectHeight')),
    })
  }
}