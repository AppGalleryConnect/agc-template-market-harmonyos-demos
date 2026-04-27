import { Logger } from 'module_ui_base'
import { AGREE_PRIVACY_KEY, PrivacyAgreementRouterMap } from '../commons/Enums'
import { PreferenceUtils } from '../utils/PreferenceUtils'

const TAG: string = '[PrivacyView]'

@ComponentV2
export struct PrivacyAgreementView {
  @Param
  stack: NavPathStack = new NavPathStack()
  @Param
  appIcon: ResourceStr = ''
  @Param
  appName: ResourceStr = ''
  @Param
  appDesc: ResourceStr = ''
  @Param
  themeColor: ResourceColor = $r('app.color.theme_color')
  @Param
  privacySummary: ResourceStr = '本应用需联网，调用XX、XX权限，获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅'
  @Param
  privacyLinkDesc: ResourceStr = 'XX业务与隐私的声明、权限使用说明'
  @Param
  privacyLink: ResourceStr = $rawfile('privacy-statement.html')
  @Event
  handleConfirm: () => void
  @Local
  openSheet: boolean = false
  @Local
  isAgree: boolean = false
  @Local
  preferInstance:PreferenceUtils = PreferenceUtils.getInstance(this.getUIContext().getHostContext()!)

  aboutToAppear(): void {
    this.isAgree = this.preferInstance.get(AGREE_PRIVACY_KEY) as boolean;
    if (this.isAgree) {
      this.handleConfirm?.()
    }
  }

  build() {
    if (!this.isAgree) {
      Stack() {
        Column() {
          Scroll() {
            Column() {
              Image(this.appIcon)
                .width(72)
                .draggable(false)
                .margin({ top: 136 })
              Text(this.appName)
                .fontSize($r('sys.float.Title_L'))
                .fontWeight(FontWeight.Medium)
                .margin({
                  top: $r('app.float.space_xl'),
                  bottom: $r('app.float.space_xs'),
                })
              Text(this.appDesc)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
            }
          }
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .layoutWeight(1)

          Column() {
            Image($r('app.media.ic_security'))
              .width(16)
              .draggable(false)
            this.confirmContentBuilder()
            Row({ space: 16 }) {
              Button('取消')
                .fontColor(this.themeColor)
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .height(40)
                .layoutWeight(1)
                .onClick(() => {
                  this.openSheet = true
                })
              Button('同意')
                .height(40)
                .backgroundColor(this.themeColor)
                .layoutWeight(1)
                .onClick(() => {
                  this.preferInstance.put(AGREE_PRIVACY_KEY, true);
                  this.handleConfirm?.()
                })
            }
            .padding({
              top: $r('app.float.space_l'),
              bottom: $r('app.float.space_l'),
            })
          }
          .constraintSize({ maxWidth: 480 })
          .margin({
            top: $r('app.float.space_m'),
          })
        }
        .layoutWeight(1)
        .padding({
          left: $r('app.float.space_l'),
          right: $r('app.float.space_l'),
          bottom: $r('app.float.space_l'),
        })

        if (this.openSheet) {
          this.doubleCheckDialog()
        }
      }
      .height($r('app.string.size_percent_full'))
      .width($r('app.string.size_percent_full'))
    }
  }

  @Builder
  doubleCheckDialog() {
    Column() {
      Column() {
        Text(`您需要同意协议才能体验${this.appName}`)
          .fontWeight(FontWeight.Bold)
          .fontSize(20)
          .margin({ top: $r('app.float.space_l') })
        this.confirmContentBuilder()
        Row({ space: 16 }) {
          Button('退出应用')
            .fontColor(this.themeColor)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .height(40)
            .layoutWeight(1)
            .onClick(() => {
              try {
                this.getUIContext().getHostContext()?.getApplicationContext().killAllProcesses();
              } catch (err) {
                Logger.error(TAG, 'kill application failed. error:' + JSON.stringify(err))
              }

            })
          Button('同意并继续')
            .height(40)
            .backgroundColor(this.themeColor)
            .layoutWeight(1)
            .onClick(() => {
              this.openSheet = false;
              this.preferInstance.put(AGREE_PRIVACY_KEY, true);
              this.handleConfirm?.()
            })
        }
        .padding({
          top: $r('app.float.space_l'),
          bottom: $r('app.float.space_l'),
        })
      }
      .padding($r('app.float.space_m'))
      .backgroundColor($r('app.color.background_color_primary'))
      .borderRadius($r('app.float.border_radius_xl'))
    }
    .height($r('app.string.size_percent_full'))
    .width($r('app.string.size_percent_full'))
    .backgroundColor($r('sys.color.mask_fourth'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
    })
    .justifyContent(FlexAlign.Center)

  }

  @Builder
  confirmContentBuilder() {
    Column() {
      Text() {
        Span(this.privacySummary)
          .fontColor($r('sys.color.font_secondary'))
        Span(this.privacyLinkDesc)
          .fontColor(this.themeColor)
          .onClick(() => {
            this.stack.pushPath({ name: PrivacyAgreementRouterMap.PRIVACY_PREVIEW, param: this.privacyLink })
          })
        Span('。')
          .fontColor($r('sys.color.font_secondary'))
      }
      .fontSize($r('sys.float.Caption_M'))
      .margin({
        top: $r('app.float.space_l'),
        bottom: $r('app.float.space_s'),
      })

      Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_secondary'))
    }
    .width('100%')
    .constraintSize({ maxWidth: 480 })
    .alignItems(HorizontalAlign.Start)
  }
}