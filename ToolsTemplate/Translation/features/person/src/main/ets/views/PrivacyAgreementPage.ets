import { BarVM, BreakpointModel, PreferenceConstant, PreferenceUtil, RouterMap } from 'common';
import { phoneRouterControl } from 'oh_router';
import { AppStorageV2 } from '@kit.ArkUI';
import { ProtocolData } from './LoginPage';
import { ProtocolRouterParams, ProtocolWebViewBuilder } from 'aggregated_login';

@Builder
export function PrivacyAgreementPageBuilder() {
  PrivacyAgreementPage()
}

// 隐私协议
@ComponentV2
export struct PrivacyAgreementPage {
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
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
              .width(72)
              .height(72)
              .margin({ bottom: 24, top: 136 })
            Text($r('app.string.app_name'))
              .fontSize($r('sys.float.Title_L'))
              .height(40)
              .fontWeight(FontWeight.Medium)
            Text($r('app.string.app_description'))
              .fontSize($r('sys.float.Body_M'))
              .height(19)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 2 })
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
            .height(24)
            .aspectRatio(1)
            .margin({ bottom: 16, top: 0 })

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
                    pageName: RouterMap.PROTOCOL_WEB_VIEW_NAME,
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
                    pageName: RouterMap.PROTOCOL_WEB_VIEW_NAME,
                    param: {
                      content: ProtocolData.privacyProtocol,
                      isSheet: false,
                    } as ProtocolRouterParams,
                    builder: wrapBuilder(ProtocolWebViewBuilder)
                  })
                })
                .fontColor($r('sys.color.font_emphasize'))
            }
            .lineHeight(13)
            .fontSize(10)
            .fontColor($r('sys.color.font_secondary'))

            Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 6, bottom: 17 })
            Row({ space: 12 }) {
              Button('取消')
                .layoutWeight(1)
                .height(40)
                .fontColor($r('sys.color.font_emphasize'))
                .fontSize($r('sys.float.Body_L'))
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .onClick(() => {
                  this.openSheet = true
                })
              Button('同意')
                .layoutWeight(1)
                .height(40)
                .fontColor($r('sys.color.font_on_primary'))
                .fontSize($r('sys.float.Body_L'))
                .backgroundColor($r('sys.color.font_emphasize'))
                .onClick(() => {
                  PreferenceUtil.getInstance(getContext()).put(PreferenceConstant.FIRST_LAUNCH, false)
                  phoneRouterControl.popPage({
                    popData: 'agree'
                  })
                })
            }
            .margin({ bottom: 12 })
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
          }
        }
        .width('100%')
        .height('100%')
        .padding({
          left: this.breakPointModel.pagePadding,
          right: this.breakPointModel.pagePadding,
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
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      this.terminateSelf()
      return true
    })
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
            pageName: RouterMap.PROTOCOL_WEB_VIEW_NAME,
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
      top: 16,
      bottom: 8,
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
          .fontSize(20)
          .margin({ top: 16 })
        this.confirmContentBuilder()
        Row({ space: 16 }) {
          Button('退出应用')
            .fontColor($r('sys.color.font_emphasize'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .height(40)
            .layoutWeight(1)
            .onClick(() => {
              this.terminateSelf()
            })
          Button('同意并继续')
            .height(40)
            .backgroundColor($r('sys.color.font_emphasize'))
            .layoutWeight(1)
            .onClick(() => {
              this.openSheet = false;
              PreferenceUtil.getInstance(getContext()).put(PreferenceConstant.FIRST_LAUNCH, false)
              phoneRouterControl.popPage({
                popData: 'agree'
              })
            })
        }
        .padding({
          top: 16,
          bottom: 16,
        })
      }
      .padding(12)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(32)
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('sys.color.mask_fourth'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .padding({
      left: 16,
      right: 16,
    })
    .justifyContent(FlexAlign.Center)
  }

  // 退出应用
  terminateSelf(): void {
    try {
      this.getUIContext().getHostContext()?.getApplicationContext().killAllProcesses();
    } catch (err) {
      Error('kill application failed. error:' + JSON.stringify(err))
    }
  }
}

