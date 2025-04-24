import { AvoidArea, CommonConstants, LeftReturnComponent, TitleBar, UserInfo } from '@ohos_agcit/common_component';
import { AppStorageV2, PersistenceV2, PromptAction, router } from '@kit.ArkUI';

@Entry
@ComponentV2
struct PersonalInformation {
  promptAction: PromptAction = this.getUIContext().getPromptAction()
  customDialogComponentId: number = 0
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  build() {
    Column() {
      Row() {
        LeftReturnComponent()
          .onClick(() => {
            router.back();
          })
        TitleBar({ text: '个人信息' })
      }
      .height('5%')
      .width(CommonConstants.FULL_WIDTH)
      .alignItems(VerticalAlign.Center)

      Column() {
        Row() {
          Text('头像')
            .fontSize($r('app.float.font_size_16'))
            .fontWeight(CommonConstants.FONT_WEIGHT_600)
          Blank()
          Button({ type: ButtonType.Circle, stateEffect: false })
            .backgroundImage(this.userInfo.isLogin && this.userInfo.avatar !== '' ? this.userInfo.avatar :
            $r('app.media.ic_avatar')
            )
            .backgroundImageSize(ImageSize.Cover)
            .backgroundColor(Color.Transparent)
            .width(45)
            .height(45)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/mine/AvatarUpload',
                params: {}
              }, router.RouterMode.Standard)
            })
          Image($r('app.media.ic_public_arrow_right'))
            .fillColor($r('sys.color.ohos_id_color_foreground'))
            .opacity(0.2)
            .width(15)
            .height(30)
        }
        .margin({ top: '8%' })
        .padding({ left: '5%', right: '2.5%' })
        .width('100%')
        .height('8%')
        .backgroundColor(Color.White)
        .borderRadius(CommonConstants.COMMON_RADIUS)

        Row() {
          Text('昵称')
            .fontSize($r('app.float.font_size_16'))
            .fontWeight(CommonConstants.FONT_WEIGHT_600)
          Blank()
          Row() {
            Text(this.userInfo.nickname)
              .fontSize($r('app.float.font_size_16'))
              .margin({ right: '2%' })
            Image($r('app.media.ic_public_arrow_right'))
              .fillColor($r('sys.color.ohos_id_color_foreground'))
              .opacity(0.2)
              .width(15)
              .height(30)
              .margin({ right: '2.5%' })
          }
          .onClick(() => {
            router.pushUrl({
              url: 'pages/mine/RenamePage',
              params: {}
            }, router.RouterMode.Standard)
          })
        }
        .margin({ top: '5%' })
        .padding({ left: '5%', right: '2.5%' })
        .width('100%')
        .height('8%')
        .backgroundColor(Color.White)
        .borderRadius(CommonConstants.COMMON_RADIUS)
      }

      Blank()

      Button('退出登录')
        .fontWeight(CommonConstants.FONT_WEIGHT_600)
        .width('90%')
        .fontColor($r('app.color.common_blue'))
        .backgroundColor($r('app.color.button_gray'))
        .onClick(() => {
          this.userInfo.isLogin = false
          this.userInfo.unionID = ''
          this.userInfo.nickname = ''
          this.userInfo.avatar = ''
          router.back()
          // this.promptAction.openCustomDialog({
          //   builder: () => {
          //     this.customDialogComponent()
          //   },
          //   onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
          //     console.info("reason" + JSON.stringify(dismissDialogAction.reason))
          //     console.log("dialog onWillDismiss")
          //     if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
          //       dismissDialogAction.dismiss()
          //     }
          //     if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
          //       dismissDialogAction.dismiss()
          //     }
          //   }
          // }).then((dialogId: number) => {
          //   this.customDialogComponentId = dialogId
          // })
        })
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.common_background'))
    .padding({
      top: px2vp(this.avoidArea.topRectHeight) + 10,
      bottom: px2vp(this.avoidArea.bottomRectHeight),
      left: '6%',
      right: '6%'
    })
  }

  @Builder
  customDialogComponent() {
    Column() {
      TextInput({ placeholder: '请输入（必填）' })
        .maxLength(18)
        .placeholderColor(Color.Grey)
        .placeholderFont({ size: 16, weight: 400 })
        .showCounter(true,
          { thresholdPercentage: 80, highlightBorder: true })
      Row({ space: 50 }) {
        Button('取消')
          .onClick(() => {
          this.promptAction.closeCustomDialog(this.customDialogComponentId)
        })
        Button('确认')
          .onClick(() => {
          this.promptAction.closeCustomDialog(this.customDialogComponentId)
        })
      }
    }
    .height(200)
    .padding(5)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}