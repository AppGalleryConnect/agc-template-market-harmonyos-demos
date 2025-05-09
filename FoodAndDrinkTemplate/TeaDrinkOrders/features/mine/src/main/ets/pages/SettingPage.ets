import { Constants, NavHeaderBar, RouterMap, WindowModel } from 'common/Index';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function SettingPageBuilder() {
  SettingPage()
}

@ComponentV2
struct SettingPage {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.setting') })
      Column() {
        Row() {
          Text($r('app.string.privacy')).fontSize(14).fontColor($r('sys.color.font_primary')).margin({ left: 12 })
          Image($r('app.media.ic_right2')).width(14).height(14)
        }
        .width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween).onClick(() => {
          this.pageStack?.pushPathByName(RouterMap.PRIVACY_PAGE, null)
        })
      }
      .width(Constants.FULL_SIZE)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
      .borderRadius(12)
      .padding(12)
      .backgroundColor($r('sys.color.background_primary'))
      .margin({
        top: 12,
        left: Constants.BORDER_WIDTH,
        right: Constants.BORDER_WIDTH,
        bottom: this.windowModel.getWindowBottomHeight(),
      })

    }.hideTitleBar(true).backgroundColor($r('sys.color.background_secondary'))
  }
}
