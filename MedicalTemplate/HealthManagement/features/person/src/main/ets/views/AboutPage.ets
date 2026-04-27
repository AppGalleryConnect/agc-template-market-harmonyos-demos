import { common } from '@kit.AbilityKit';
import { ComponentContent } from '@kit.ArkUI';
import { CommonHeader, BarVM } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { checkUpdate, DialogController, findNewVersion, Params } from 'check_app_update';
import { call } from '@kit.TelephonyKit';


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
    DialogController.setOptions({ alignment: DialogAlignment.Center, offset: { dx: 0, dy: 0 } as Offset })
    DialogController.openDialog();
  }

  aboutToAppear(): void {
    this.checkUpdateVersion()
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: $r('app.string.person_about_title'),
        leftImageRes: $r('app.media.ic_backward2'),
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })

      Scroll() {
        Column() {
          Image($r('app.media.login_icon'))
            .width($r('app.float.vp_72'))
            .height($r('app.float.vp_72'))
            .margin({ top: $r('app.float.vp_62'), bottom: $r('app.float.vp_8') })
          Text($r('app.string.person_about_app_name'))
            .fontSize($r('sys.float.Subtitle_M'))
            .lineHeight($r('app.float.vp_22'))
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
                  Text($r('app.string.person_about_version_info'))
                    .fontSize($r('sys.float.Body_L'))
                    .height($r('app.float.vp_22'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .margin({ top: $r('app.float.vp_2') })
                }
                .height($r('app.float.vp_22'))
                .width($r('app.float.vp_74'))
                .margin({ bottom: $r('app.float.vp_2') })

                Text($r('app.string.person_about_version'))
                  .fontSize($r('sys.float.Body_M'))
                  .lineHeight($r('app.float.vp_20'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))
              }
              .alignItems(HorizontalAlign.Start)

              Blank()
              Text(this.needUpdate
                ? $r('app.string.person_about_wait_update')
                : $r('app.string.person_about_new_version'))
                .fontWeight(FontWeight.Regular)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
              Image($r('app.media.iconRight'))
                .size({ width: $r('app.float.vp_18'), height: $r('app.float.vp_18') })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .height($r('app.float.vp_64'))
            .onClick(() => {
              // 点击按钮后切换“模拟更新”功能
              if (this.needUpdate === false) {
                this.needUpdate = true
                this.getUIContext()
                  .getPromptAction()
                  .showToast({ message: $r('app.string.person_about_new_version') })
              } else {
                this.needUpdate = false
                this.checkAppUpdate()
              }
            })

            Divider().width('100%')
              .color($r('sys.color.comp_divider'))
              .strokeWidth('1px')

            Row() {
              Column() {
                Text($r('app.string.person_about_service_call'))
                  .fontSize($r('sys.float.Body_L'))
                  .lineHeight($r('app.float.vp_22'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ top: $r('app.float.vp_2') })

                Text($r('app.string.person_about_service_phone'))
                  .fontSize($r('sys.float.Body_M'))
                  .lineHeight($r('app.float.vp_20'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))
              }
              .alignItems(HorizontalAlign.Start)
            }
            .height($r('app.float.vp_64'))
            .width('100%')
            .onClick(() => {
              try {
                if (canIUse('SystemCapability.Applications.Contacts')) {
                  call.makeCall('900800');
                }
              } catch (err) {
              }
            })
          }
          .backgroundColor($r('sys.color.comp_background_primary'))
          .width('100%')
          .margin({ top: 61 })
          .padding({
            top: $r('app.float.vp_4'),
            left: $r('app.float.vp_12'),
            right: $r('app.float.vp_12'),
            bottom: $r('app.float.vp_4')
          })
          .borderRadius($r('sys.float.corner_radius_level8'))

          Blank().layoutWeight(1)

          Column() {
            Text($r('app.string.person_about_copyright_number'))
              .fontSize($r('sys.float.Body_S'))
              .lineHeight($r('app.float.vp_16'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.color_0A59F7'))
            Text($r('app.string.person_about_copyright'))
              .fontSize($r('sys.float.Body_S'))
              .lineHeight($r('app.float.vp_16'))
              .fontWeight(FontWeight.Regular)
              .opacity(0.6)
            Text($r('app.string.person_about_technology'))
              .fontSize($r('sys.float.Body_S'))
              .lineHeight($r('app.float.vp_16'))
              .fontWeight(FontWeight.Regular)
              .opacity(0.6)
          }
          .width('100%')

          Blank().height(px2vp(BarVM.instance.aiBarH))
        }
        .justifyContent(FlexAlign.Start)
        .backgroundColor($r('sys.color.background_secondary'))
        .width('100%')
        .layoutWeight(1)
        .padding({
          bottom: $r('app.float.vp_16')
        })
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .enableScrollInteraction(true)
      .layoutWeight(1)
    }
    .width('100%').height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true
    })
  }
}

@Builder
export
function

AboutPageBuilder() {
  AboutPage()
}
