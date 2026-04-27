import { SettingPageVM } from '../viewModels/SettingPageVM';
import { TipsDialog } from '@kit.ArkUI';
import { RouterModule } from 'lib_foundation';
import { RouterMap } from 'module_base';


@Builder
export function SettingPageBuilder() {
  SettingPage();
}

@ComponentV2
export struct SettingPage {
  vm: SettingPageVM = SettingPageVM.instance
  dialogControllerLogout: CustomDialogController = new CustomDialogController({
    builder: TipsDialog({
      content: '是否确认退出登录?',
      primaryButton: {
        value: '取消',
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.logout()
        },
      },
    }),
  })

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Row() {
              Text('推送通知')
                .fontSize(16)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))

              Toggle({ type: ToggleType.Switch, isOn: true })
            }
            .contentStyles()
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 12 })

            Row() {
              Text('清除缓存')
                .fontSize(16)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))

              Row() {
                Text(this.vm.size.toString())
                  .fontSize(16)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))

                Image($r('app.media.ic_arrow_right'))
                  .width(12)
                  .height(12)
              }
            }
            .contentStyles()
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              this.vm.clearCache()
            })
            .margin({ bottom: 12 })

            Row() {
              this.contentBuilder('隐私政策')
            }
            .margin({ bottom: 12 })

            this.contentBuilder('用户协议')
          }
          .margin({
            left: 16,
            right: 16,
          });
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }
      .layoutWeight(1)

      if (this.vm.userInfoModel.isLogin) {
        Row() {
          Button('退出登录')
            .fontColor($r('sys.color.font_emphasize'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .width('100%')
            .borderRadius(20)
            .onClick(() => {
              this.dialogControllerLogout.open()
            });
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
      }
    }
    .title('设置')
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  contentBuilder(title: string) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))

      Row() {
        Image($r('app.media.ic_arrow_right'))
          .width(12)
          .height(12)
      }
    }
    .contentStyles()
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      RouterModule.push({ url: RouterMap.PRIVACY_PAGE })
    })
  }

  @Styles
  contentStyles(){
    .width('100%')
    .padding({
      top: 20,
      bottom: 20,
      left: 18,
      right: 18,
    })
    .borderRadius(16)
    .backgroundColor(Color.White)
  }
}