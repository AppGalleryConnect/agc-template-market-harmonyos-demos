import {
  BaseResponse,
  Constants,
  HttpCode,
  HttpRequestApi,
  NavHeaderBar,
  UserIconModel,
  UserInfo,
  UserInfoModel,
  UserSexEnum,
} from 'common/Index';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2, PersistenceV2, promptAction } from '@kit.ArkUI';
import fs from '@ohos.file.fs';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';

@Builder
export function UserInfoPageBuilder() {
  UserInfoPage()
}

@ComponentV2
struct UserInfoPage {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local userIconInfo: UserIconModel = PersistenceV2.connect(UserIconModel, () => new UserIconModel())!;
  @Local nickName: string = this.userInfo.userInfo.name
  @Local selectMale: boolean = this.userInfo.userInfo.sex !== UserSexEnum.female
  @Local userIconPath: string = this.userIconInfo.userIconPath
  @Local isSaved: boolean = this.userIconInfo.isSaved

  @Computed
  get avatarUri(): string {
    return `file://${getContext().filesDir}/${this.userIconPath}`
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.complete_user_info') })
      Column() {
        Stack() {
          FunctionalButton({
            params: {
              // OpenType.CHOOSE_AVATAR表示Button为选择头像类型
              openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
              label: '',
              // 调整Button样式
              styleOption: {
                styleConfig: new functionalButtonComponentManager.ButtonConfig()
                  .type(ButtonType.Normal)
                  .backgroundImage(this.isSaved ? this.avatarUri : $r('app.media.ic_user_img'))
                  .backgroundImageSize(ImageSize.Cover)
                  .width(80)
                  .height(80)
                  .borderRadius(50)
                  .backgroundColor('#E5E5E5'),
              },
            },
            // OpenType为“CHOOSE_AVATAR”时，回调必须选择“onChooseAvatar”
            controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err,
              data) => {
              if (err) {
                // 错误日志处理
                hilog.error(0x0000, 'testTag', 'error： %{public}d %{public}s', err.code, err.message);
                return;
              }
              // 成功日志处理
              hilog.info(0x0000, 'testTag', 'succeeded in choosing avatar');
              let file: fs.File = null!;
              try {
                file = fs.openSync(data.avatarUri, fs.OpenMode.READ_ONLY)
                this.userIconPath = `${util.generateRandomUUID(false)}.jpg`
                let imagePath = `${getContext().filesDir}/${this.userIconPath}`
                fs.copyFileSync(file.fd, imagePath)
                this.isSaved = true
              } catch (error) {
                let err: BusinessError = error as BusinessError;
                console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
              } finally {
                fs.closeSync(file);
              }
            }),
          })
          Image($r('app.media.ic_camera')).width(32).offset({ x: 34, y: 21 })
        }.width(Constants.FULL_SIZE).margin({ top: 54 }).alignContent(Alignment.Center)

        Column() {
          Text($r('app.string.nickname')).fontSize(16).fontColor($r('sys.color.font_primary'))
          TextInput({ text: $$this.nickName, placeholder: $r('app.string.inputMsg') })
            .placeholderFont({ size: 10 })
            .placeholderColor($r('sys.color.mask_secondary'))
            .fontSize(10)
            .fontColor($r('sys.color.mask_secondary'))
            .padding({
              left: 12,
              right: 12,
              top: 7,
              bottom: 7,
            })
            .margin({ top: 8 })
        }.alignItems(HorizontalAlign.Start).margin({ top: 70 })

        Column() {
          Row() {
            Text($r('app.string.sex')).fontSize(16).fontColor($r('sys.color.font_primary'))
            Text($r('app.string.sex_note'))
              .fontSize(12)
              .fontColor($r('sys.color.font_primary'))
              .opacity(0.4)
              .margin({ left: 8 })
          }

          Row({ space: 8 }) {
            Row() {
              Image(this.selectMale ? $r('app.media.ic_male_select') : $r('app.media.ic_male')).width(24)
              Text($r('app.string.select_male'))
                .fontSize(14)
                .fontColor(this.selectMale ? '#62B42E' : $r('sys.color.font_primary'))
                .margin({ left: 12 })
            }
            .padding({
              top: 14,
              bottom: 14,
            })
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.selectMale ? '#3362B42E' : 'rgba(25,25,25,0.05)')
            .borderRadius(24)
            .layoutWeight(1)
            .onClick(() => {
              if (!this.userInfo.userInfo.sex) {
                this.selectMale = true
              }
            })

            Row() {
              Image(this.selectMale ? $r('app.media.ic_female') : $r('app.media.ic_female_select')).width(24)
              Text($r('app.string.select_female'))
                .fontSize(14)
                .fontColor(this.selectMale ? $r('sys.color.font_primary') : '#62B42E')
                .margin({ left: 12 })
            }
            .justifyContent(FlexAlign.Center)
            .padding({
              top: 14,
              bottom: 14,
            })
            .backgroundColor(this.selectMale ? 'rgba(25,25,25,0.05)' : '#3362B42E')
            .borderRadius(24)
            .layoutWeight(1)
            .onClick(() => {
              if (!this.userInfo.userInfo.sex) {
                this.selectMale = false
              }
            })
          }.margin({ top: 8 })
        }.alignItems(HorizontalAlign.Start).margin({ top: 35 })

        Row() {
          Text($r('app.string.complete'))
            .fontSize(14)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .padding({ top: 6, bottom: 6 })
        }
        .width(Constants.FULL_SIZE)
        .height(40)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .margin({ left: 8, right: 8, top: 92 })
        .backgroundColor('#486602')
        .borderRadius(16)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          if (!this.nickName) {
            promptAction.showToast({ message: $r('app.string.input_nickname') })
            return
          }
          this.modifyUserInfo()
        })

      }.padding({ left: 24, right: 24 })
    }.hideTitleBar(true)
  }

  modifyUserInfo() {
    HttpRequestApi.modifyUserInfo(this.nickName, this.selectMale ? 1 : 2).then((resp: BaseResponse<UserInfo>) => {
      if (resp.code === HttpCode.SUCCESS) {
        promptAction.showToast({ message: $r('app.string.modify_success') })
        this.userInfo.userInfo = resp.data
        this.userIconInfo.userIconPath = this.userIconPath
        this.userIconInfo.isSaved = this.isSaved
        this.pageStack?.pop()
      } else {
        promptAction.showToast({ message: $r('app.string.modify_failed') })
      }
    }).catch((e: BusinessError) => {
      console.error(`modifyUserInfo error: ${JSON.stringify(e)}.`);
      promptAction.showToast({ message: $r('app.string.modify_failed', JSON.stringify(e)) })
    })
  }
}
