import { AppRouter, CommonFuncResult,
  Constants, maskPhone, UserApi,
  UserInfoStorage } from 'common'
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit'
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { PersistenceV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { BaseTitle, GlobalDialog } from 'components';

@Builder
export function userInfoSettingPageBuilder() {
  UserInfoSettingPage()
}

@ComponentV2
export struct UserInfoSettingPage {
  @Local userInfoStorage: UserInfoStorage = PersistenceV2.connect(UserInfoStorage, 'UserInfoStorage', () => new UserInfoStorage())!

  updateUserInfo() {
    let userParam: Record<string, string> = {
      'idToken': this.userInfoStorage.userInfo.idToken,
      'authCode': this.userInfoStorage.userInfo.authCode,
      'avatar': this.userInfoStorage.userInfo.avatar,
      'phoneNumber': this.userInfoStorage.userInfo.phoneNumber,
      'userName': this.userInfoStorage.userInfo.userName
    }
    UserApi.updateUserInfo(userParam).then((res) => {
      let result = res.result as CommonFuncResult
      if (result.ret.code === 0) {
        GlobalDialog.showToast('修改成功')
      } else {
        console.error(`errorCode: ${result.ret.code}, message: ${result.ret.desc}`);
      }
    })
  }

  getUserAvatar(): ResourceStr {
    // 用户登录
    if (this.userInfoStorage.isLogin) {
      let userInfoAvatar = this.userInfoStorage.userInfo.avatar
      // 判断是否是沙箱路径
      if (userInfoAvatar.startsWith('file://')) {
        let sandboxPath = userInfoAvatar.split('file://')[1]
        // 判断沙箱路径的图片是否存在，不存在，则使用默认头像
        if (!fs.accessSync(sandboxPath)) {
          return $r('app.media.ic_default_avatar')
        }
      }
      return userInfoAvatar || $r('app.media.ic_default_avatar')
    }
    return $r('app.media.ic_default_avatar')
  }

  build() {
    NavDestination() {
      Column() {
        BaseTitle({
          title: '个人信息',
          bgColor: $r('sys.color.white'),
          showBackBtn: true,
          onBack: () => {
            AppRouter.pop()
          }
        })

        Column({space: 12}) {
          // 头像
          Column() {
            UserInfoItem({
              text: '头像',
              rightBuilder: () => {
                this.AvatarRightView()
              }
            })
          }
          .width(Constants.FULL_PERCENT_WIDTH)
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
          .width(Constants.FULL_PERCENT_WIDTH)
          .backgroundColor($r('sys.color.white'))
          .padding({left: 12, right:12, top:18, bottom: 18})
          .borderRadius(16)
        }
        .padding({left: 16, top: 12, right: 16})
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .height(Constants.FULL_PERCENT_HEIGHT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.color_page_bg'))
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
            this.userInfoStorage.userInfo.avatar = 'file://' + imagePath
            this.updateUserInfo()
          } catch (error) {
            let err: BusinessError = error as BusinessError;
            console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
          } finally {
            fs.closeSync(file);
          }
        }),
      })
      Image($r('app.media.ic_right_arrow'))
        .width(24)
        .height(24)
        .fillColor($r('sys.color.ohos_id_color_text_tertiary'))
    }
  }
  @Builder
  UserNameRightView() {
    Row({space: 4}) {
      Text(this.userInfoStorage.userInfo.userName)
        .fontSize(14).fontWeight(FontWeight.Regular)
        .fontColor('#99000000')
      Image($r('app.media.ic_right_arrow'))
        .width(24)
        .height(24)
        .fillColor($r('sys.color.ohos_id_color_text_tertiary'))
    }
    .onClick(() => {
      GlobalDialog.showDialogWithInputBox({
        hint: '修改昵称',
        content: this.userInfoStorage.userInfo.userName,
        textLength: 10,
        placeholder: '请输入昵称',
        but1Name: '取消',
        but2Name: '确定',
        onConfirm: (value?: string) => {
          this.userInfoStorage.userInfo.userName = value || this.userInfoStorage.userInfo.userName;
          this.updateUserInfo()
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
    Text(maskPhone(this.userInfoStorage.userInfo.phoneNumber))
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
    .width(Constants.FULL_PERCENT_WIDTH)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.white'))
    .padding({top: 12, bottom: 12 })
  }
}