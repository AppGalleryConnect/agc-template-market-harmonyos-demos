import { GridRowColSetting, LoginState, ScreenPropStorage } from 'external_interactions';
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function SettingPageBuilder() {
  SettingPage()
}

@ComponentV2
export struct SettingPage {
  @Local screenPropStorage : ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () =>new ScreenPropStorage())!
  @Local loginStateStorage : LoginState = AppStorageV2.connect(LoginState, 'LoginState', () => new LoginState())!
  @Local loginState: boolean = this.loginStateStorage.loginState;
  @Local topRectHeight: number = this.screenPropStorage.topRectHeight;
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      TitleBar({ title: '设置',
        onBackClick:()=>{
          this.pathStack.pop()
        }
      })
        .margin({ left: 16, right: 16 })

      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({
          span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
          offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
        }) {
          Row() {
            Text('个人信息')
              .fontSize(16)
              .margin({ left: 12 })

            Image($r('app.media.right_arrow'))
              .width(16)
              .height(16)
              .fillColor($r('sys.color.icon_primary'))
              .margin({ right: 12 })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('90%')
          .height(56)
          .borderRadius(20)
          .backgroundColor(Color.White)
          .onClick(() => {
            this.pathStack.pushPath({ name: 'vip/MineInfoPage', param: this.loginState })
          })
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
    })
  }
}