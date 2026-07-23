import { common } from '@kit.AbilityKit';
import { getMedia, NAV_PAGE_NAME } from '@agctemplate/resources';
import { appRouter, PreferConstant, PreferenceUtil, WindowManager } from '@agctemplate/utils';
import { ComponentContent, window } from '@kit.ArkUI';

export class PromptActionClass {
  static ctx: UIContext;
  static contentNode: ComponentContent<Object>;

  static setContext(context: UIContext) {
    PromptActionClass.ctx = context;
  }

  static setContentNode(node: ComponentContent<Object>) {
    PromptActionClass.contentNode = node;
  }

  static openDialog() {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction().openCustomDialog(PromptActionClass.contentNode)
    }
  }

  static closeDialog() {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction().closeCustomDialog(PromptActionClass.contentNode)
    }
  }
}

// 隐私协议
@ComponentV2
export struct PrivacyAgreementPage {
  private permissionList: string[] = ['XX', 'XX']
  @Local information: string = 'XX'
  @Local service: string = 'XX'
  @Local business: string = 'XX业务与隐私声明'
  private ctx: UIContext = this.getUIContext();
  private contentNode: ComponentContent<Object> =
    new ComponentContent(this.ctx, wrapBuilder(privacyDialog));

  aboutToAppear(): void {
    PromptActionClass.setContext(this.ctx);
    PromptActionClass.setContentNode(this.contentNode);
    WindowManager.setWindowSystemBarEnable(['navigation'])
  }

  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.ic_launch'))
          .width(72)
          .height(72)
          .margin({ bottom: 24, top: '17%' })
        Text('短剧')
          .fontSize($r('sys.float.Title_L'))
          .height(40)
          .fontWeight(FontWeight.Medium)
        Text('业务描述')
          .fontSize($r('sys.float.Body_M'))
          .height(19)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 2 })
        Blank()
        Stack({ alignContent: Alignment.Center }) {
          Image(getMedia('app.media.ic_security_shield'))
            .size({ height: 22.52 })
          Text()
            .backgroundColor($r('sys.color.icon_emphasize'))
            .size({ width: 2.74, height: 6.5 })
            .zIndex(1)
        }
        .height(24)
        .aspectRatio(1)
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
              appRouter.push({ builderName: NAV_PAGE_NAME.PrivacyStatementPage.name })
            })
            .fontColor('#EC6E45')
          Span('、')
          Span('权限使用说明')
            .onClick(() => {
              appRouter.push({ builderName: NAV_PAGE_NAME.PrivacyStatementPage.name })
            })
            .fontColor('#EC6E45')
        }
        .lineHeight(13)
        .fontSize(10)
        .fontColor($r('sys.color.font_secondary'))

        Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 6, bottom: 17 })
        Row() {
          Button('取消')
            .id('cancel')
            .width('48%')
            .height(40)
            .fontColor('#EC6E45')
            .fontSize($r('sys.float.Body_L'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              PromptActionClass.openDialog()
            })
          Button('同意')
            .width('48%')
            .height(40)
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize($r('sys.float.Body_L'))
            .backgroundColor('#EC6E45')
            .onClick(() => {
              PreferenceUtil.getInstance(this.getUIContext().getHostContext()).put(PreferConstant.FIRSTLAUNCH, false)
              appRouter.replace({ builderName: NAV_PAGE_NAME.LaunchAdPage.name })
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
      }
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16,
        top: '9%',
        bottom: 36
      })
      .justifyContent(FlexAlign.Start)
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      try {
        (this.getUIContext().getHostContext() as common.UIAbilityContext).terminateSelf()
      } catch (e) {
        console.error(`terminateSelf failed: ${e}`);
      }
      return true
    })
  }
}

const windowStage: window.WindowStage = AppStorage.get('windowStage')!

@Builder
export function privacyDialog() {
  Stack({ alignContent: Alignment.Center }) {
    Column() {
      Text('您需要同意协议才能体验短剧')
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
          Span(
            '获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅')
          Span('XX业务与隐私声明')
            .onClick(() => {
              PromptActionClass.closeDialog()
              appRouter.push({ builderName: NAV_PAGE_NAME.PrivacyStatementPage.name })
            })
            .fontColor('#EC6E45')
          Span('、')
          Span('权限使用说明')
            .onClick(() => {
              PromptActionClass.closeDialog()
              appRouter.push({ builderName: NAV_PAGE_NAME.PrivacyStatementPage.name })
            })
            .fontColor('#EC6E45')
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
              (windowStage.getMainWindowSync().getUIContext().getHostContext() as
                common.UIAbilityContext).terminateSelf()
            } catch (e) {
              console.error(`terminateSelf failed: ${e}`);
            }
          })
          .width(140)
          .height(40)
          .fontColor($r('sys.color.warning'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .margin({ right: 16 })
        Button('同意并继续')
          .onClick(() => {
            PromptActionClass.closeDialog()
            PreferenceUtil.getInstance(windowStage.getMainWindowSync().getUIContext().getHostContext())
              .put(PreferConstant.FIRSTLAUNCH, false)
            appRouter.replace({ builderName: NAV_PAGE_NAME.LaunchAdPage.name })
          })
          .width(140)
          .height(40)
          .fontColor('sys.color.font_on_primary')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#EC6E45')
      }
    }
    .justifyContent(FlexAlign.Start)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .borderRadius(10)
    .height(229)
    .width(328)
  }
}

@Builder
export function PrivacyAgreementBuilder() {
  PrivacyAgreementPage()
}