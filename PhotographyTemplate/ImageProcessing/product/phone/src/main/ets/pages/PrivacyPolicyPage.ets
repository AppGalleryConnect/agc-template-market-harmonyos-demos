import { AppStorageV2, window } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit';
import { UIDialog } from '@hw-agconnect/ui-dialog'
import {
  CommonConstants,
  GridRowColSetting,
  Logger,
  PreferConstant,
  PreferenceUtil,
  RouterMap,
  RouterModule,
  WindowSize,
} from 'commonlib'


@Builder
export function PrivacyPolicyBuilder() {
  PrivacyPolicy()
}

@ComponentV2
struct PrivacyPolicy {
  @Local windowSize: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!

  @Computed
  get iconMargin() {
    const isSplitScreen = this.windowSize.windowStatusType === window.WindowStatusType.SPLIT_SCREEN;
    return isSplitScreen ? 0 : 136;
  }

  privacyClick() {
    RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_PAGE, param: true })
  }

  openPrivacyDialog() {
    UIDialog.open({
      titleOptions: {
        primaryTitle: '您需要同意协议才能体验功能',
      },
      contentBuilder: () => {
        this.contentBuilder()
      },
      actionBuilder: () => {
        this.actionBuilder();
      },
      closeOnClickMask: false,
      closeOnBackPress: false,
    })
  }

  quiteApp() {
    const uiContext: UIContext = this.getUIContext();
    const ctx = uiContext.getHostContext() as common.UIAbilityContext;
    ctx.terminateSelf().catch((e: BusinessError) => {
      Logger.error('[PrivacyPolicy]', 'terminateSelf fail, error: ' + JSON.stringify(e))
    });
  }

  agree() {
    PreferenceUtil.getInstance().put(PreferConstant.PRIVACY_POLICY_KEY, '1');
    RouterModule.replace({ url: RouterMap.SPLASH_PAGE });
  }

  build() {
    NavDestination() {
      GridRow({
        columns: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
      }) {
        GridCol({
          span: { xs: 4, sm: 4, md: 6, lg: 8 },
          offset: { md: 1, lg: 2 },
        }) {
          Column() {
            Column() {
              Image($r('app.media.app_icon'))
                .width(72)
                .draggable(false)
                .margin({ top: this.iconMargin })
                .borderRadius(16)
              Text('拍照美化')
                .fontSize($r('sys.float.Title_L'))
                .fontWeight(FontWeight.Medium)
                .margin({ top: 24, bottom: 2 })
              Text('业务描述')
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
            }
            .width(CommonConstants.FULL_PERCENT)
            .layoutWeight(1)

            Column({ space: CommonConstants.SPACE_L }) {
              Image($r('app.media.ic_security'))
                .width($r('app.float.vp_24'))
                .draggable(false)

              this.documentBuilder()

              Row({ space: CommonConstants.SPACE_M }) {
                Button('取消')
                  .fontColor($r('sys.color.multi_color_aux_01'))
                  .backgroundColor($r('sys.color.comp_background_tertiary'))
                  .height(40)
                  .layoutWeight(1)
                  .onClick(() => {
                    this.openPrivacyDialog()
                  })
                Button('同意')
                  .height(40)
                  .backgroundColor($r('sys.color.multi_color_aux_01'))
                  .layoutWeight(1)
                  .onClick(() => {
                    this.agree();
                  })
              }
              .padding({ top: CommonConstants.PADDING_L, bottom: CommonConstants.PADDING_L })
            }
          }
          .height(CommonConstants.FULL_PERCENT)
          .width(CommonConstants.FULL_PERCENT)
          .padding({
            left: CommonConstants.PADDING_L,
            right: CommonConstants.PADDING_L,
            top: this.windowSize.statusHeight,
            bottom: this.windowSize.bottomHeight,
          })
        }
      }
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  documentBuilder() {
    Column({ space: CommonConstants.SPACE_S }) {
      Text() {
        Span('本应用需')
        Span('联网').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
        Span('，调用XX、XX权限，获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅')
        Span('XX业务与隐私的声明、权限使用说明')
          .fontWeight(FontWeight.Medium)
          .fontColor('#4B5CC4')
          .onClick(() => {
            this.privacyClick();
          })
        Span('。')
      }
      .fontSize($r('sys.float.Caption_M'))
      .fontColor($r('sys.color.font_secondary'))

      Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_secondary'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  contentBuilder() {
    Column() {
      this.documentBuilder()
    }
    .padding({
      left: CommonConstants.PADDING_XXL,
      right: CommonConstants.PADDING_XXL,
      top: CommonConstants.PADDING_L,
    })
  }

  @Builder
  actionBuilder() {
    Row({ space: CommonConstants.SPACE_M }) {
      Button('退出应用')
        .type(ButtonType.ROUNDED_RECTANGLE)
        .fontColor($r('sys.color.multi_color_aux_01'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .layoutWeight(1)
        .onClick(() => {
          this.quiteApp();
        })
      Button('同意并继续')
        .type(ButtonType.ROUNDED_RECTANGLE)
        .backgroundColor($r('sys.color.multi_color_aux_01'))
        .layoutWeight(1)
        .onClick(() => {
          this.agree();
        })
    }
    .padding({
      left: CommonConstants.PADDING_L,
      right: CommonConstants.PADDING_L,
      top: CommonConstants.PADDING_L,
    })
  }
}