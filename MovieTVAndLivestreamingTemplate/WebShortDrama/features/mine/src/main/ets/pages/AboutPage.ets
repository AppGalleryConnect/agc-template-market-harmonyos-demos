import { Header } from '../component/Header'
import { common } from '@kit.AbilityKit'
import { AppStorageV2, promptAction } from '@kit.ArkUI'
import { AppStorageKeys, FontModel, fp2pxUtil, StatusBarHeight } from '@agctemplate/widgets';

// 关于
@ComponentV2
export struct AboutPage {
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local information: string = 'XX'
  @Local service: string = 'XX'
  @Local business: string = 'XX业务与隐私声明'
  @Local needUpdate: boolean = false;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  // 检查更新
  checkAppUpdate() {
    // AppGalleryUtils.checkAppUpdate(getContext() as common.UIAbilityContext)
    //   .then((hasUpdate) => {
    //     if (hasUpdate) {
    //       this.needUpdate = true;
    //     }
    //   })
    //   .catch((error: Error) => {
    //     console.log('===>', JSON.stringify(error))
    //   });
  }

  aboutToAppear(): void {

  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          Header({ title: '关于' })
          Image($r('app.media.logo'))
            .width(72)
            .height(72)
            .margin({ top: 62, bottom: 8 })
          Text('短剧模板')
            .fontSize(this.fontModel.getFg(16))
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
                    .fontSize(this.fontModel.getFg(16))
                    .height(this.fontModel.getDesFg(21))
                    .fontWeight(500)
                    .fontColor($r('sys.color.font_primary'))
                    .margin({ top: 2 })
                }
                .height(this.fontModel.getDesFg(21))
                .width(this.fontModel.getDesFg(74))
                .margin({ bottom: 2 })

                Text('10.15.1')
                  .fontSize(this.fontModel.getFg(14))
                  .height(this.fontModel.getDesFg(19))
                  .fontWeight(400)
                  .fontColor($r('sys.color.font_secondary'))
              }
              .alignItems(HorizontalAlign.Start)

              Blank()
              Text(this.needUpdate ? '待更新' : '已是最新版本')
                .fontWeight(400)
                .fontSize(this.fontModel.getFg(14))
                .fontColor($r('sys.color.font_secondary'))
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize(this.fontModel.getFg(18))
                .fontColor([$r('sys.color.icon_fourth')])
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .height(this.fontModel.getDesFg(64))
            .onClick(() => {
              this.getUIContext().getPromptAction().showToast({ message: '已是最新版本' })
            })

            Divider().width('100%').height(0.5).color($r('sys.color.comp_divider'))

            Row() {
              Column() {
                Text('客服电话')
                  .fontSize(this.fontModel.getFg(16))
                  .height(this.fontModel.getDesFg(21))
                  .fontWeight(500)
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ top: 2 })

                Text('900800')
                  .fontSize(this.fontModel.getFg(14))
                  .height(this.fontModel.getDesFg(19))
                  .fontWeight(400)
                  .fontColor($r('sys.color.font_secondary'))
              }
              .alignItems(HorizontalAlign.Start)
            }
            .height(this.fontModel.getDesFg(64))
            .width('100%')
          }
          .backgroundColor($r('sys.color.comp_background_primary'))
          .width(328)
          .margin({ top: 61 })
          .padding({
            top: 4,
            left: 12,
            right: 12,
            bottom: 4
          })
          .borderRadius(16)
        }
        .justifyContent(FlexAlign.Start)
        .backgroundColor($r('sys.color.background_secondary'))
        .width('100%')
        .height('100%')
        .padding({ top: `${this.getUIContext().px2vp(this.statusBarHeight.value)}vp`, bottom: 36 })

        Column() {
          Text('苏ICP备17040376号-135A')
            .fontSize(fp2pxUtil(12))
            .lineHeight(16)
            .fontWeight(500)
            .fontColor('#0A59F7')
          Text('华为xx 版权所有 © 2019-2023')
            .fontSize(fp2pxUtil(12))
            .lineHeight(16)
            .fontWeight(400)
            .opacity(0.6)
          Text('技术支持：xxxxxxxx')
            .fontSize(fp2pxUtil(12))
            .lineHeight(16)
            .fontWeight(400)
            .opacity(0.6)
        }
        .width('100%')
        .padding({ bottom: 86 })
      }
    }.hideTitleBar(true)
  }
}

@Builder
export function AboutPageBuilder() {
  AboutPage()
}