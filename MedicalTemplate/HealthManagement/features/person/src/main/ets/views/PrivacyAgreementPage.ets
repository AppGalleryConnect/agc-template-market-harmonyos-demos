import { PreferenceConstant, PreferenceUtil } from 'common';
import { phoneRouterControl } from 'oh_router';
import { BarVM } from 'common';
import { ProtocolData, ProtocolRouterParams, ProtocolWebViewBuilder, protocolWebViewName } from 'aggregated_login';
import { common } from '@kit.AbilityKit';

@Builder
export function PrivacyAgreementPageBuilder() {
  PrivacyAgreementPage()
}

@ComponentV2
export struct PrivacyAgreementPage {
  private permissionList: string[] = ['XX', 'XX']
  @Local openSheet: boolean = false
  @Local information: string = 'XX'
  @Local service: string = 'XX'
  @Local business: string = 'XX业务与隐私声明'

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Column() {
            Image($r('app.media.startIcon'))
              .width($r('app.float.vp_72'))
              .height($r('app.float.vp_72'))
              .margin({ bottom: $r('app.float.vp_24'), top: $r('app.float.vp_136') })
            Text($r('app.string.app_name'))
              .fontSize($r('sys.float.Title_L'))
              .lineHeight($r('app.float.vp_40'))
              .fontWeight(FontWeight.Medium)
            Text($r('app.string.app_description'))
              .fontSize($r('sys.float.Body_M'))
              .lineHeight($r('app.float.vp_20'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: $r('app.float.vp_2') })
          }

          Column() {
            Stack({ alignContent: Alignment.Center }) {
              Image($r('app.media.ic_pre_exam2'))
                .size({ height: 22.52 })
              Text()
                .backgroundColor($r('sys.color.icon_emphasize'))
                .size({ width: 2.74, height: 6.5 })
                .zIndex(1)
            }
            .height($r('app.float.vp_24'))
            .aspectRatio(1)
            .margin({ bottom: $r('app.float.vp_16'), top: 0 })

            Text() {
              Span('本应用需')
              Span('联网')
                .fontColor($r('sys.color.font_primary'))
              Span('，调用')
              ForEach(this.permissionList, (item: string, index) => {
                Span(item)
                  .fontColor($r('sys.color.font_primary'))
                if (index !== this.permissionList.length - 1) {
                  Span('、')
                }
              }
                , (item: string, index: number) => item + index)
              Span('权限，')
              Span('获取' + `${this.information}` + '信息，以为您提供' + `${this.service}` +
                '服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅')
              Span(this.business)
                .onClick(() => {
                  phoneRouterControl.jumpPage({
                    pageName: protocolWebViewName,
                    param: {
                      content: ProtocolData.privacyProtocol,
                      isSheet: false,
                    } as ProtocolRouterParams,
                    builder: wrapBuilder(ProtocolWebViewBuilder)
                  })
                })
                .fontColor($r('sys.color.font_emphasize'))
              Span('、')
              Span('权限使用说明')
                .onClick(() => {
                  phoneRouterControl.jumpPage({
                    pageName: protocolWebViewName,
                    param: {
                      content: ProtocolData.privacyProtocol,
                      isSheet: false,
                    } as ProtocolRouterParams,
                    builder: wrapBuilder(ProtocolWebViewBuilder)
                  })
                })
                .fontColor($r('sys.color.font_emphasize'))
            }
            .lineHeight($r('app.float.vp_14'))
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_secondary'))

            Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: $r('app.float.vp_6'), bottom: $r('app.float.vp_16') })
            Row({ space: 12 }) {
              Button('取消')
                .layoutWeight(1)
                .height($r('app.float.vp_40'))
                .fontColor($r('sys.color.font_emphasize'))
                .fontSize($r('sys.float.Body_L'))
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .onClick(() => {
                  this.openSheet = true
                })
              Button('同意')
                .layoutWeight(1)
                .height($r('app.float.vp_40'))
                .fontColor($r('sys.color.font_on_primary'))
                .fontSize($r('sys.float.Body_L'))
                .backgroundColor($r('sys.color.font_emphasize'))
                .onClick(() => {
                  PreferenceUtil.getInstance(this.getUIContext().getHostContext() as common.UIAbilityContext)
                    .put(PreferenceConstant.FIRST_LAUNCH, false)
                  phoneRouterControl.popPage({
                    popData: 'agree'
                  })
                })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
          }
        }
        .width('100%')
        .height('100%')
        .padding({
          left: $r('app.float.vp_16'),
          right: $r('app.float.vp_16'),
          top: BarVM.instance.staBarH,
          bottom: BarVM.instance.aiBarH
        })
        .justifyContent(FlexAlign.SpaceBetween)

        if (this.openSheet) {
          this.doubleCheckDialog()
        }
      }
      .height('100%')
      .width('100%')
    }.hideTitleBar(true)
  }

  @Builder
  confirmContentBuilder() {
    Text() {
      Span('本应用需联网，调用XX、XX权限，获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅')
        .fontColor($r('sys.color.font_secondary'))
      Span('XX业务与隐私的声明、权限使用说明')
        .fontColor($r('sys.color.font_emphasize'))
        .onClick(() => {
          phoneRouterControl.jumpPage({
            pageName: protocolWebViewName,
            param: {
              content: ProtocolData.privacyProtocol,
              isSheet: false,
            } as ProtocolRouterParams,
            builder: wrapBuilder(ProtocolWebViewBuilder)
          })
        })
      Span('。')
        .fontColor($r('sys.color.font_secondary'))
    }
    .fontSize($r('sys.float.Caption_M'))
    .margin({
      top: $r('app.float.vp_16'),
      bottom: $r('app.float.vp_8'),
    })

    Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
      .fontSize($r('sys.float.Caption_M'))
      .fontColor($r('sys.color.font_secondary'))
  }

  @Builder
  doubleCheckDialog() {
    Column() {
      Column() {
        Text(`您需要同意协议才能体验本应用`)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Title_S'))
          .margin({ top: $r('app.float.vp_16') })
        this.confirmContentBuilder()
        Row({ space: 16 }) {
          Button('退出应用')
            .fontColor($r('sys.color.font_emphasize'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .height($r('app.float.vp_40'))
            .layoutWeight(1)
            .onClick(() => {
              try {
                this.getUIContext().getHostContext()?.getApplicationContext().killAllProcesses();
              } catch (err) {
                Error('kill application failed. error:' + JSON.stringify(err))
              }
            })
          Button('同意并继续')
            .height($r('app.float.vp_40'))
            .backgroundColor($r('sys.color.font_emphasize'))
            .layoutWeight(1)
            .onClick(() => {
              this.openSheet = false;
              PreferenceUtil.getInstance(this.getUIContext().getHostContext() as common.UIAbilityContext)
                .put(PreferenceConstant.FIRST_LAUNCH, false)
              phoneRouterControl.popPage({
                popData: 'agree'
              })
            })
        }
        .padding({
          top: $r('app.float.vp_16'),
          bottom: $r('app.float.vp_16'),
        })
      }
      .padding($r('app.float.vp_12'))
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius($r('sys.float.corner_radius_level16'))
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('sys.color.mask_fourth'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
    })
    .justifyContent(FlexAlign.Center)
  }
}

