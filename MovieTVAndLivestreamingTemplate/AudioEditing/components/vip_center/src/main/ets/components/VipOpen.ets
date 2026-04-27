import { display, promptAction } from '@kit.ArkUI'

@ComponentV2
export struct VipOpen {
  @Local isAgreed: boolean = false
  @Event onVipOpen: () => void = () => {
  }
  @Param pageInfo: NavPathStack = new NavPathStack()

  build() {
    Column({ space: 16 }) {
      Row() {
        Checkbox({ name: 'checkbox1', group: 'checkboxGroup' })
          .select(this.isAgreed)
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .onChange((value) => {
            this.isAgreed = value
          })
          .width(14)
          .height(14)
        Text() {
          Span('开通前请阅读并同意')
            .fontColor($r('sys.color.font_secondary'))
          Span('《会员服务协议》')
            .fontColor('#562E15')
            .onClick(() => {
              this.pageInfo.pushPathByName('ServiceAgreement', null)
            })
        }
        .fontWeight(FontWeight.Medium)
        .fontSize(12)
      }

      Button('立即开通')
        .backgroundColor('#F1D1A5')
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .width('100%')
        .onClick(() => {
          if (!this.isAgreed) {
            promptAction.showToast({ message: '请阅读并勾选协议' })
            return
          }
          this.onVipOpen()
        })
    }
    .padding({ left: 16, right: 16 })
    .margin({
      top: this.marginTop()
    })
  }

  // 阔折叠适配距离顶部高度
  marginTop(): string {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      if (display.getFoldDisplayMode() === display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL &&
        display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED) {
        return '5%'
      }
    }
    return '30%'
  }
}