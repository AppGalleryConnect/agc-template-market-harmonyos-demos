import { AppStorageV2, display, window } from '@kit.ArkUI';
import { RouterMap, RouterModule } from '@agctemplate/router_module';
import { Header } from '../component/Header';
import { AppStorageKeys, BarVM, BreakPoint, BreakPointValue } from '@agctemplate/widgets';
import { UserInfoRow } from '../component/UserInfoRow';
import { deviceInfo } from '@kit.BasicServicesKit';

@ComponentV2
export struct PrivacySettingsPage {
  @Local bottomHeight: number = 0;
  @Local isPersonalized: boolean = false
  @Local isVersionCheckSheet: boolean = false
  @Local breakPoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint())!;
  @Local isLandScapeTablet: boolean = display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
    display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED &&
      deviceInfo.deviceType === 'tablet'
  callback: Callback<number> = (data: number) => {
    if (display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
      display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED &&
        deviceInfo.deviceType === 'tablet') {
      this.isLandScapeTablet = true
    } else {
      this.isLandScapeTablet = false
    }
  }

  aboutToAppear(): void {
    try {
      window.getLastWindow(this.getUIContext().getHostContext(), (_err, data) => {
        const avoidAreaBottom = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.bottomHeight = avoidAreaBottom.bottomRect.height;
      })
      display.on('change', this.callback)
    } catch (e) {
    }
  }

  aboutToDisappear(): void {
    try {
      display.off('change', this.callback)
    } catch (e) {
    }
  }

  @Builder
  line() {
    Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider')).padding({ left: 12, right: 12 })
  }

  build() {
    NavDestination() {
      Column() {
        Header({ title: '隐私设置' })
        Scroll() {
          Column() {
            Column() {
              GenericCard() {
                Personalized({
                  switchButton: (isOn) => {
                    this.isPersonalized = isOn
                  }
                })
              }

              GenericCard() {
                UserInfoRow({
                  leftTitle: '用户协议',
                  rightOnClick: () => {
                    RouterModule.push({ url: RouterMap.TERMS_SERVICE_PAGE })
                  }
                })
                this.line()
                UserInfoRow({
                  leftTitle: '隐私政策',
                  rightOnClick: () => {
                    RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_PAGE })
                  }
                })
              }

              GenericCard() {
                UserInfoRow({
                  leftTitle: '第三方信息共享清单',
                  rightOnClick: () => {
                    RouterModule.push({ url: RouterMap.PRIVACY_3RD_PARTY_SHARE_PAGE })
                  }
                })
                this.line()
                UserInfoRow({
                  leftTitle: '个人信息收集清单',
                  rightOnClick: () => {
                    RouterModule.push({ url: RouterMap.PRIVACY_INFO_COLLECT_PAGE })
                  }
                })
              }
            }
            .height(388)

          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width(this.breakPoint.value === BreakPointValue.LG ? '70%' : '100%')
          .height('100%')
          .padding({
            left: 16,
            right: 16,
            bottom: this.bottomHeight
          })
        }
        .height('100%')
        .align(Alignment.TopStart)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .padding({ bottom: BarVM.instance.aiBarH })
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
    .hideTitleBar(true)
    .padding({ top: BarVM.instance.staBarH, bottom: BarVM.instance.aiBarH })
  }
}

@Builder
export function PrivacySettingsPageBuilder() {
  PrivacySettingsPage()
}

@ComponentV2
export struct GenericCard {
  @BuilderParam content: () => void

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .borderRadius(16)
    .margin({ top: 8, bottom: 6 })
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }
}

@ComponentV2
export struct Personalized {
  @Param leftTitle: string = '个性化推荐'
  @Param subTitle: string = '想我推荐审核我的个性化内容'
  @Event switchButton: (isOn: boolean) => void
  @Local isToggleOn: boolean = false

  build() {
    Row() {
      Column({ space: 2 }) {
        Text(this.leftTitle)
          .height(21)
        if (this.subTitle) {
          Text(this.subTitle).height(19).fontWeight(400).fontSize(14).fontColor($r('sys.color.font_secondary'))
        }
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Toggle({ type: ToggleType.Switch, isOn: this.isToggleOn })
        .size({ width: 36, height: 20 })
        .onChange(() => {
          this.isToggleOn = !this.isToggleOn
          if (this.switchButton) {
            this.switchButton(this.isToggleOn)
          }
        })
    }
    .size({ width: '100%', height: 64 })
    .padding({ left: 12, right: 12 })
  }
}
