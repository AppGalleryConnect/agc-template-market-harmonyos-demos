import { CommonHeader } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { checkUpdate, DialogController, findNewVersion, Params } from 'check_app_update';
import { call } from '@kit.TelephonyKit';

// 关于
@ComponentV2
export struct AboutPage {
  @Local information: string = 'XX'
  @Local service: string = 'XX'
  @Local business: string = 'XX业务与隐私声明'
  @Local needUpdate: boolean = false;
  private ctx: UIContext = this.getUIContext();

  checkUpdateVersion() {
    checkUpdate(this.getUIContext().getHostContext() as common.UIAbilityContext)
      .then(version => {
        // 0 不存在新版本， 1 存在新版本
        if (version === 1) {
          this.needUpdate = true
        } else {
          this.needUpdate = false
        }
      })
  }

  checkAppUpdate() {
    checkUpdate(this.getUIContext().getHostContext() as common.UIAbilityContext)
      .then(version => {
        // 0 不存在新版本， 1 存在新版本
        if (version === 1) {
          this.needUpdate = true
          this.showCallDialog(version);
        } else {
          // 已经是最新版本
          // 模拟更新弹窗
          this.showCallDialog(version);
        }
      })
  }

  showCallDialog(version: number) {
    DialogController.setContext(this.ctx);
    let contentNode: ComponentContent<object> =
      new ComponentContent(this.ctx, wrapBuilder(findNewVersion), new Params(version))
    DialogController.setContentNode(contentNode);
    DialogController.setOptions({ alignment: DialogAlignment.Center, offset: { dx: 0, dy: 0 } })
    DialogController.openDialog();
  }

  aboutToAppear(): void {
    this.checkUpdateVersion()
  }

  @Builder
  render() {
    Scroll() {
      Column() {
        CommonHeader({
          title: '关于',
          onReturnClick: () => {
            phoneRouterControl.popPage();
          },
        })
        Column() {
          Image($r('app.media.startIcon'))
            .width(72)
            .height(72)
            .margin({ top: 62, bottom: 8 })
          Text('旅游攻略')
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
              // 点击按钮后切换“模拟更新”功能
              if (this.needUpdate === false) {
                this.needUpdate = true
                promptAction.showToast({ message: '已是最新版本' })
              } else {
                this.needUpdate = false
                this.checkAppUpdate()
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

                Text('9800XXXX')
                  .fontSize(14)
                  .height(19)
                  .fontWeight(400)
                  .fontColor($r('sys.color.font_secondary'))
              }
              .alignItems(HorizontalAlign.Start)
            }
            .height(64)
            .width('100%')
            .onClick(() => {
              try {
                if (canIUse('SystemCapability.Applications.Contacts')) {
                  call.makeCall('9800XXXX');
                }
              } catch (err) {
              }
            })
          }
          .backgroundColor($r('sys.color.comp_background_primary'))
          .width('100%')
          .margin({ top: 61, bottom: 244 })
          .padding({
            top: 4,
            left: 12,
            right: 12,
            bottom: 4
          })
          .borderRadius(16)

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

        }
        .justifyContent(FlexAlign.Start)
        .backgroundColor($r('sys.color.background_secondary'))
        .width('100%')
        .height('100%')
      }
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: true,
      useSafePadding: true,
      pageBackgroundColor: $r('sys.color.background_secondary')
    })
  }
}

@Builder
export function AboutPageBuilder() {
  AboutPage()
}