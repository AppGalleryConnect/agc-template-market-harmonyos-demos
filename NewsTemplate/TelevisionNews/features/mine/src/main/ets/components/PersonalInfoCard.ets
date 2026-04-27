import { UtilLog } from '@hw-agconnect/util-log';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import fs from '@ohos.file.fs';
import { Constants } from 'lib_common';
import { MineVM } from '../viewmodels/MineVM';

const TAG = '[PersonalInfoCard]'

@ComponentV2
export struct PersonalInfoCard {
  vm: MineVM = new MineVM(this.getUIContext())

  @Computed
  get avatarUri(): ResourceStr {
    return this.vm.userInfoModel.isSaved ?
      `file://${this.getUIContext().getHostContext()?.filesDir}/${this.vm.userInfoModel.userIconPath}` :
      $r('app.media.ic_default_relative')
  }

  build() {
    Row() {
      Row() {
        if (this.vm.userInfoModel.isRelative) {
          FunctionalButton({
            params: {
              // OpenType.CHOOSE_AVATAR表示Button为选择头像类型
              openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
              label: '',
              // 调整Button样式
              styleOption: {
                styleConfig: new functionalButtonComponentManager.ButtonConfig()
                  .type(ButtonType.Normal)
                  .backgroundImage(this.avatarUri)
                  .backgroundImageSize(ImageSize.Cover)
                  .width(48)
                  .height(48)
                  .borderRadius(24)
                  .backgroundColor('#E5E5E5'),
              },
            },
            // OpenType为“CHOOSE_AVATAR”时，回调必须选择“onChooseAvatar”
            controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err,
              data) => {
              if (err) {
                // 错误日志处理
                UtilLog.error(TAG, 'error： %{public}d %{public}s', err.code, err.message);
                return;
              }
              // 成功日志处理
              UtilLog.info(TAG, 'succeeded in choosing avatar');
              let file: fs.File = null!;
              try {
                file = fs.openSync(data.avatarUri, fs.OpenMode.READ_ONLY)
                if (!file) {
                  this.getUIContext().getPromptAction().showToast({ message: '头像获取失败' })
                  return
                }
                this.vm.userInfoModel.userIconPath = `${util.generateRandomUUID(false)}.jpg`
                let imagePath = `${this.getUIContext().getHostContext()?.filesDir}/${this.vm.userInfoModel.userIconPath}`
                fs.copyFileSync(file.fd, imagePath)
                this.vm.userInfoModel.isSaved = true
              } catch (error) {
                let err: BusinessError = error as BusinessError;
                UtilLog.error(TAG, `PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
              } finally {
                if (file) {
                  fs.closeSync(file);
                }
              }
            }),
          })
        } else {
          Image($r('app.media.ic_default_hd'))
            .width(48)
            .height(48)
            .borderRadius(24)
        }

        Column() {
          if (this.vm.userInfoModel.isRelative) {
            Text(this.vm.userInfoModel.authorNickName)
              .fontSize($r('sys.float.Subtitle_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))

            Row() {
              Image($r('app.media.icon_phone')).width(16)
              Text(this.vm.userInfoModel.authorPhone)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
                .margin({ left: 2 })
            }.margin({ top: 12, left: 1 })
          } else {
            Text('华为用户').fontSize($r('sys.float.Subtitle_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
      }

      Column() {
        if (this.vm.userInfoModel.isRelative) {
          Row({ space: 4 }) {
            SymbolGlyph($r('sys.symbol.link_slash'))
              .fontSize(16)
              .fontColor(['#FFFFFF', '#E6FFFFFF'])
            Text('取消关联')
              .fontSize($r('sys.float.Body_M'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_on_primary'))
              .height(20)
          }
          .padding({
            left: 8,
            right: 8,
            top: 4,
            bottom: 4,
          })
          .borderRadius(14)
          .backgroundColor(this.vm.userInfoModel.isRelative ? '#EB5544':
            $r('sys.color.background_secondary'))
          .onClick(() => {
            this.vm.toMultiAccount()
          })
        } else {
          Stack() {
            SymbolGlyph($r('sys.symbol.link'))
              .fontSize(16)
              .fontColor([$r('sys.color.icon_secondary'), '#000000'])
            FunctionalButton({
              params: {
                // OpenType.GET_PHONE_NUMBER表示该按钮用于快速验证手机号码。
                openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
                label: '关联账户',
                // 调整按钮样式。
                styleOption: {
                  styleConfig: new functionalButtonComponentManager.ButtonConfig()
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor($r('sys.color.font_primary'))
                    .backgroundColor('#00000000')
                    .height(20)
                    .padding(0)
                    .align(Alignment.End),
                },
              },
              // 当OpenType为GET_PHONE_NUMBER时，回调必须为onGetPhoneNumber。
              controller: new functionalButtonComponentManager.FunctionalButtonController()
                .onGetPhoneNumber((err, data) => {
                  if (err) {
                    // 错误日志处理。
                    UtilLog.error(TAG, 'error: %{public}d %{public}s', err.code, err.message);
                    // todo 未获取权限时模拟登录成功
                    this.vm.bindPhoneMock()
                    return;
                  }
                  // 成功日志处理。
                  UtilLog.info(TAG, 'succeeded in authenticating');
                  // 授权码处理。
                  let authorizationCode = data.code;
                  if (authorizationCode) {
                    this.vm.login(authorizationCode)
                  } else {
                    this.getUIContext().getPromptAction().showToast({ message: '账号关联失败' })
                  }
                }),
            })
              .margin({ left: 20 })
              .zIndex(1)
          }
          .alignContent(Alignment.Start)
          .padding({
            left: 8,
            right: 8,
            top: 4,
            bottom: 4,
          })
          .borderRadius(14)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
        }
      }
      .height(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.End)
    }
    .width(Constants.FULL_SIZE)
    .justifyContent(FlexAlign.SpaceBetween)
    .height(72)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding(12)
  }

}
