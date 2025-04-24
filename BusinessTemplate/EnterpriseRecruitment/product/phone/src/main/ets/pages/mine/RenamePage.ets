import { AvoidArea, CommonConstants, LeftReturnComponent, TitleBar, UserInfo, User } from '@ohos_agcit/common_component';
import { AppStorageV2, PersistenceV2, router } from '@kit.ArkUI';

@Entry
@ComponentV2
struct RenamePage {
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local input: string = ''

  build() {
    Column() {
      Row() {
        LeftReturnComponent()
          .onClick(() => {
            router.back();
          })
        TitleBar({ text: '修改昵称' })
      }
      .height('5%')
      .width(CommonConstants.FULL_WIDTH)
      .alignItems(VerticalAlign.Center)
      
      Column() {
        TextInput({ text: this.userInfo.nickname, placeholder: 'input your resume...'})
          .type(InputType.Normal)
          .fontSize($r('app.float.font_size_20'))
          .backgroundColor(Color.Transparent)
          .fontWeight(CommonConstants.FONT_WEIGHT_500)
          .textAlign(TextAlign.Start)
          .border({ width: 0 })
          .borderRadius(0)
          .onChange((input: string) => {
            this.input = input
          })
          .width('100%')
          .height('100%')
          .maxLength(18)
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: 16, weight: 400 })
          .showCounter(true,
            { thresholdPercentage: 80, highlightBorder: true })
      }
      .width('100%')
      .height('7%')
      .backgroundColor(Color.White)
      .borderRadius(CommonConstants.COMMON_RADIUS)
      .margin({top: '8%'})
      
      Blank()
      
      Button('保存')
        .fontWeight(CommonConstants.FONT_WEIGHT_600)
        .width('90%')
        .fontColor($r('app.color.common_blue'))
        .backgroundColor($r('app.color.button_gray'))
        .onClick(() => {
          let user = this.userInfo.users.get(this.userInfo.unionID) as User
          user.nickname = this.input
          this.userInfo.nickname = this.input
          router.back()
        })

    }
    .backgroundColor($r('app.color.common_background'))
    .height('100%')
    .width('100%')
    .padding({
      top: px2vp(this.avoidArea.topRectHeight) + 10,
      bottom: px2vp(this.avoidArea.bottomRectHeight),
      left: '6%',
      right: '6%'
    })
  }
}