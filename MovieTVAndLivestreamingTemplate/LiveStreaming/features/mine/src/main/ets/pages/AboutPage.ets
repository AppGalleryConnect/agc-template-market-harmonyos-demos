import { BarVM } from '@agctemplate/widgets'
import { Header } from '../component/Header'
import { AppGalleryUtils } from '../utils/AppGalleryUtils'
import { common } from '@kit.AbilityKit'
import { display, promptAction } from '@kit.ArkUI'
import { deviceInfo } from '@kit.BasicServicesKit'

// 关于
@ComponentV2
export struct AboutPage {
  @Local information: string = 'XX'
  @Local service: string = 'XX'
  @Local business: string = 'XX业务与隐私声明'
  @Local needUpdate: boolean = false;
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
  private uiContext: UIContext = this.getUIContext();

  // 检查更新
  checkAppUpdate() {
    AppGalleryUtils.checkAppUpdate(this.uiContext.getHostContext() as common.UIAbilityContext)
      .then((hasUpdate) => {
        if (hasUpdate) {
          this.needUpdate = true;
        }
      })
      .catch((error: Error) => {
        console.log('===>', JSON.stringify(error))
      });
  }

  aboutToAppear(): void {
    try {
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

  build() {
    NavDestination() {
      Column() {
        Header({ title: '关于' })
        Column() {
          Image($r('app.media.logo1'))
            .width(72)
            .height(72)
            .margin({ top: 62, bottom: 8 })
          Text('直播')
            .fontSize(16)
            .height(21)
            .fontWeight(FontWeight.Medium)

          Column() {
            Row() {
              Column() {
                Badge({
                  value: '',
                  position: BadgePosition.Right,
                  style: {
                    badgeSize: this.needUpdate ? 6 : 0, badgeColor: $r('sys.color.warning')
                  }
                }) {
                  Text('版本信息')
                    .fontSize(16)
                    .height(21)
                    .fontWeight(500)
                    .fontColor($r('sys.color.font_primary'))
                    .margin({ top: 2 })
                }
                .height(21)
                .width(74)
                .margin({ bottom: 2 })

                Text('10.15.1')
                  .fontSize(14)
                  .height(19)
                  .fontWeight(400)
                  .fontColor($r('sys.color.font_secondary'))
              }
              .alignItems(HorizontalAlign.Start)

              Blank()
              Text(this.needUpdate ? '待更新' : '已是最新版本')
                .fontWeight(400)
                .fontSize(14)
                .fontColor($r('sys.color.font_secondary'))
              Image($r('app.media.iconRight'))
                .size({ width: 18, height: 18 })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .height(64)
            .onClick(() => {
              if (this.needUpdate) {
                AppGalleryUtils.showUpdateDialog(this.uiContext.getHostContext() as common.UIAbilityContext)
              } else {
                this.uiContext.getPromptAction().showToast({ message: '已是最新版本' })
              }
            })

            Divider().width('100%').height(0.5).color($r('sys.color.comp_divider'))

            Row() {
              Column() {
                Text('客服电话')
                  .fontSize(16)
                  .height(21)
                  .fontWeight(500)
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ top: 2 })

                Text('900800')
                  .fontSize(14)
                  .height(19)
                  .fontWeight(400)
                  .fontColor($r('sys.color.font_secondary'))
              }
              .alignItems(HorizontalAlign.Start)
            }
            .height(64)
            .width('100%')
          }
          .backgroundColor($r('sys.color.comp_background_primary'))
          .width(this.isLandScapeTablet ? '70%' : '90%')
          .margin({ top: 61 })
          .padding({
            top: 4,
            left: 12,
            right: 12,
            bottom: 4
          })
          .borderRadius(16)

          Blank()
          Column() {
            Text('苏ICP备17040376号-135A')
              .fontSize(12)
              .lineHeight(16)
              .fontWeight(500)
              .fontColor('#0A59F7')
            Text('华为xx 版权所有 © 2019-2023')
              .fontSize(12)
              .lineHeight(16)
              .fontWeight(400)
              .opacity(0.6)
            Text('技术支持：xxxxxxxx')
              .fontSize(12)
              .lineHeight(16)
              .fontWeight(400)
              .opacity(0.6)
          }
          .width('100%')
          .margin({ bottom: 116 })
        }
        .justifyContent(FlexAlign.Start)
        .backgroundColor($r('sys.color.background_secondary'))
        .width('100%')
        .height('100%')
      }
      .width('100%').height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({ top: BarVM.instance.staBarH, bottom: BarVM.instance.aiBarH })
    }.hideTitleBar(true)
  }
}

@Builder
export function AboutPageBuilder() {
  AboutPage()
}