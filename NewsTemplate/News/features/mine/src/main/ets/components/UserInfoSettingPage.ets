import { RouterModule } from 'commonlib'
import { BaseTitle, GlobalDialog } from 'componentlib'
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit'
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { maskPhone } from '../utils/Util';
import { UserInfoStorage } from '../viewModels/MainPageVM';
import { PersistenceV2 } from '@kit.ArkUI';


@Builder
export function userInfoSettingPageBuilder() {
  UserInfoSettingPage()
}

@ComponentV2
export struct UserInfoSettingPage {
  @Local userInfoStorage: UserInfoStorage = PersistenceV2.connect(UserInfoStorage, 'UserInfoStorage', () => new UserInfoStorage())!

  getUserAvatar(): ResourceStr {
    if (this.userInfoStorage.avatar) {
      // 判断是否是沙箱路径
      if (this.userInfoStorage.avatar.startsWith('file://')) {
        let sandboxPath = this.userInfoStorage.avatar.split('file://')[1]
        // 判断沙箱路径的图片是否存在，不存在，则使用默认头像
        if (!fs.accessSync(sandboxPath)) {
          return $r('app.media.ic_default_hd')
        }
      }
      return this.userInfoStorage.avatar || $r('app.media.ic_default_hd')
    }
    return $r('app.media.ic_default_hd')
  }



  build() {
    NavDestination() {
      Column() {
        Column({space: 12}) {
          Column() {
            UserInfoItem({
              text: '头像',
              rightBuilder: () => {
                this.AvatarRightView()
              }
            })
          }
          .width('100%')
          .backgroundColor($r('sys.color.white'))
          .padding({left: 12, right: 12 })
          .borderRadius(16)

          Column({space: 12}) {
            UserInfoItem({
              text: '昵称',
              rightBuilder: () => {
                this.UserNameRightView()
              }
            })

            Divider().strokeWidth(0.5).color($r('sys.color.ohos_id_color_button_divider'))

            UserInfoItem({
              text: '电话',
              rightBuilder: () => {
                this.PhoneRightView()
              }
            })
          }
          .width('100%')
          .backgroundColor($r('sys.color.white'))
          .padding({left: 12, right:12, top:18, bottom: 18})
          .borderRadius(16)
        }
        .padding({left: 16, top: 12, right: 16})
      }
      .width('100%')
      .height('100%')
    }
    .title('个人信息')
    .backgroundColor('#fff5f3f3')
  }

  @Builder
  AvatarRightView() {
    Row({space: 4}) {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
          label: '',
          styleOption: {
            styleConfig: new functionalButtonComponentManager.ButtonConfig()
              .type(ButtonType.Normal)
              .backgroundImage(this.getUserAvatar())
              .backgroundImageSize(ImageSize.Cover)
              .width(40)
              .height(40)
              .borderRadius(30)
              .backgroundColor('#E5E5E5'),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err, data) => {
          if (err) {
            return;
          }
          // 成功日志处理
          let file: fs.File = null!;
          try {
            file = fs.openSync(data.avatarUri, fs.OpenMode.READ_ONLY)
            let avatar = `${util.generateRandomUUID(false)}.jpg`
            let imagePath = `${getContext().filesDir}/${avatar}`
            fs.copyFileSync(file.fd, imagePath)
            this.userInfoStorage.avatar = 'file://' + imagePath
          } catch (error) {
            let err: BusinessError = error as BusinessError;
            console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
          } finally {
            fs.closeSync(file);
          }
        }),
      })
      Image($r('app.media.right_arrow'))
        .width(24)
        .height(24)
        .fillColor($r('sys.color.ohos_id_color_text_tertiary'))
    }
  }
  @Builder
  UserNameRightView() {
    Row({space: 4}) {
      Text(this.userInfoStorage.userName)
        .fontSize(14).fontWeight(FontWeight.Regular)
        .fontColor('#99000000')
      Image($r('app.media.right_arrow'))
        .width(24)
        .height(24)
        .fillColor($r('sys.color.ohos_id_color_text_tertiary'))
    }
    .onClick(() => {
      GlobalDialog.showDialogWithInputBox({
        hint: '修改昵称',
        content: this.userInfoStorage.userName,
        textLength: 10,
        placeholder: '请输入昵称',
        but1Name: '取消',
        but2Name: '确定',
        onConfirm: (value?: string) => {
          this.userInfoStorage.userName = value ?? ''
          GlobalDialog.close()
        },
        onCancel: () => {
          GlobalDialog.close()
        }
      })
    })
  }
  @Builder
  PhoneRightView() {
    Text(maskPhone(this.userInfoStorage.phoneNumber))
      .fontSize(14).fontWeight(FontWeight.Regular)
      .fontColor('#99000000')
  }
}

@ComponentV2
struct UserInfoItem {
  @Param text: string = ''
  @Builder
  rightViewBuilder() {
  };
  @BuilderParam rightBuilder: () => void = this.rightViewBuilder;

  build() {
    Row() {
      Text(this.text).fontSize(16).fontWeight(FontWeight.Medium)

      this.rightBuilder()
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.white'))
    .padding({top: 12, bottom: 12 })
  }
}