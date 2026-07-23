import { common } from '@kit.AbilityKit';
import { RouterMap, RouterModule } from '@agctemplate/router_module';
// import { NAV_PAGE_NAME } from '@agctemplate/resources';
import { PreferConstant, PreferenceUtil } from '@agctemplate/utils';
import { BarVM } from '@agctemplate/widgets';
import { display } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';

// 隐私协议
@ComponentV2
export struct PrivacyAgreementPage {
  private permissionList: string[] = ['XX', 'XX']
  @Local information: string = 'XX'
  @Local service: string = 'XX'
  @Local business: string = 'XX业务与隐私声明'
  @Local isExpanded: boolean = display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED
  @Local isLandScape: boolean = display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
    display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED
  private uiContext: UIContext = this.getUIContext();
  callback: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    if (data === display.FoldStatus.FOLD_STATUS_EXPANDED) {
      this.isExpanded = true
    } else if (data === display.FoldStatus.FOLD_STATUS_FOLDED) {
      this.isExpanded = false
    }
  }
  callback2: Callback<number> = (data: number) => {
    if (display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
      display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED)
    {
      this.isLandScape = true
    }
    else
    {
      this.isLandScape = false
    }
  }

  aboutToAppear(): void {
    try {
      display.on('change', this.callback2)
      display.on('foldStatusChange', this.callback)
    } catch (e) {
    }
  }

  aboutToDisappear(): void {
    try {
      display.off('change', this.callback2)
      display.off('foldStatusChange', this.callback)
    } catch (e) {
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Image($r('app.media.logo1'))
            .width(72)
            .height(72)
            .margin({ bottom: 24, top: 136 })
          Text('直播')
            .fontSize($r('sys.float.Title_L'))
            .height(40)
            .fontWeight(FontWeight.Medium)
          Text('业务描述')
            .fontSize($r('sys.float.Body_M'))
            .height(19)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 2 })
        }
        .width('100%')
        .height('100%')
        .padding({
          left: 16,
          right: 16,
          top: BarVM.instance.staBarH,
          bottom: BarVM.instance.aiBarH
        })
        .justifyContent(FlexAlign.Start)

        Column() {

          Image($r('app.media.security_shield'))
            .size({ width: 32, height: 32 })
            .margin({ bottom: 16 })

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
                RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_PAGE })
              })
              .fontColor('#EE5D1A')
            Span('、')
            Span('权限使用说明')
              .onClick(() => {
                RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_PAGE })
              })
              .fontColor('#EE5D1A')
          }
          .lineHeight(13)
          .fontSize(10)
          .fontColor($r('sys.color.font_secondary'))

          Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 6, bottom: 17 })
            .width('100%')
          Row({ space: 18 }) {
            Button('取消')
              .width('48%')
              .height(40)
              .fontColor('#EE5D1A')
              .fontSize($r('sys.float.Body_L'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .onClick(() => {
                RouterModule.push({
                  url: RouterMap.PRIVACY_USE_PAGE, onPop: () => {
                    RouterModule.replace({ url: RouterMap.MAIN_PAGE })
                  }
                })
              })
            Button('同意')
              .width('48%')
              .height(40)
              .fontColor($r('sys.color.font_on_primary'))
              .fontSize($r('sys.float.Body_L'))
              .backgroundColor('#EE5D1A')
              .onClick(() => {
                PreferenceUtil.getInstance(this.uiContext.getHostContext()).put(PreferConstant.FIRSTLAUNCH, false)
                RouterModule.replace({ url: RouterMap.MAIN_PAGE })
              })
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
        }
        .width(this.isExpanded ? '80%' : deviceInfo.deviceType === 'phone' ? '100%' : this.isLandScape ? '50%' : '90%')
        .height(this.isExpanded ? '80%' : deviceInfo.deviceType === 'phone' ? '100%' : '90%')
        .padding({
          left: 16,
          right: 16,
          top: BarVM.instance.staBarH,
          bottom: BarVM.instance.aiBarH
        })
        .justifyContent(FlexAlign.End)
      }
    }.hideTitleBar(true)
  }
}

@ComponentV2
export struct PrivacyUseAlert {
  @Local information: string = 'XX'
  @Local service: string = 'XX'
  @Local business: string = 'XX业务与隐私声明'
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('sys.color.mask_fourth'))
        .opacity(0.4)

        Column() {
          Text('您需要同意协议才能体验直播')
            .lineHeight(27)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
            .margin({
              left: 24,
              right: 24,
              top: 15,
              bottom: 15
            })
          Column() {
            Text() {
              Span('本应用需')
              Span('联网')
                .fontColor($r('sys.color.font_primary'))
              Span('，调用')
              Span('XX')
                .fontColor($r('sys.color.font_primary'))
              Span('、')
              Span('XX')
                .fontColor($r('sys.color.font_primary'))
              Span('获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅')
              Span(this.business)
                .onClick(() => {
                  RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_PAGE })
                })
                .fontColor('#EE5D1A')
              Span('、')
              Span('权限使用说明')
                .onClick(() => {
                  RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_PAGE })
                })
                .fontColor('#EE5D1A')
            }
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_secondary'))

            Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 15 })
          }.height(92).margin({ left: 24, right: 24, bottom: 24 })

          Row() {
            Button('退出应用')
              .onClick(() => {
                try {
                  this.context.terminateSelf()
                } catch (e) {
                  console.error(`terminateSelf failed: ${e}`);
                }
              })
              .width(140)
              .height(40)
              .fontColor('#EE5D1A')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .margin({ right: 16 })
            Button('同意并继续')
              .onClick(() => {
                PreferenceUtil.getInstance(this.context).put(PreferConstant.FIRSTLAUNCH, false)
                RouterModule.pop<string>('agree')
              })
              .width(140)
              .height(40)
              .fontColor('sys.color.font_on_primary')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#EE5D1A')
          }
        }
        .justifyContent(FlexAlign.Start)
        .backgroundColor($r('sys.color.comp_background_primary'))
        .borderRadius(10)
        .height(229)
        .width(328)
      }
    }.hideTitleBar(true)
  }
}

@Builder
export function PrivacyUseAlertBuilder() {
  PrivacyUseAlert()
}

@Builder
export function PrivacyAgreementBuilder() {
  PrivacyAgreementPage()
}