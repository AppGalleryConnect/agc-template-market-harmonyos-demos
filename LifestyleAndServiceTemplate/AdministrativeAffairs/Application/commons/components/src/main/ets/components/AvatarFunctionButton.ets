import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { UserState } from 'common';
import fs from '@ohos.file.fs';
import { PersistenceV2 } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

@ComponentV2
export struct AvatarFunctionButton {
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;
  @Param avatarSize: number = 24

  build() {
    // 声明FunctionalButton
    FunctionalButton({
      params: {
        // OpenType.CHOOSE_AVATAR表示Button为快速获取头像
        openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
        label: '',
        // 调整Button样式
        styleOption: {
          styleConfig: new functionalButtonComponentManager.ButtonConfig()
            .type(ButtonType.Normal)
            .backgroundImage(this.userState.isLogin ?
            this.userState.userInfo.avatar :
            $r('app.media.avatar_grey'))
            .backgroundImageSize(ImageSize.Cover)
            .margin({ right: $r('app.float.mine_avatar_margin_right') })
            .width(this.avatarSize)
            .height(this.avatarSize)
            .borderRadius('50%')
            .backgroundColor('#E5E5E5'),
        },
      },
      // OpenType为“GET_PHONE_NUMBER”时，回调必须选择“onChooseAvatar”
      controller: new functionalButtonComponentManager.FunctionalButtonController()
        .onChooseAvatar((err, data) => {
          if (err) {
            return;
          }
          // 成功日志处理
          let file: fs.File = null!;
          try {
            file = fs.openSync(data.avatarUri, fs.OpenMode.READ_ONLY)
            this.userState.userInfo.avatar = `${util.generateRandomUUID(false)}.jpg`

            let imagePath = `${getContext().filesDir}/${this.userState.userInfo.avatar}`
            fs.copyFileSync(file.fd, imagePath)
            this.userState.userInfo.avatar = 'file://' + imagePath
          } catch (error) {
            let err: BusinessError = error as BusinessError;
            console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
          } finally {
            fs.closeSync(file);
          }
        }),
    })
  }
}