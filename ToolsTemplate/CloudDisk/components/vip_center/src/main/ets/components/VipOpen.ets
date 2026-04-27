import { display, promptAction } from '@kit.ArkUI'

/**
 * @usage: 用于VIP会员开通场景。提供服务协议勾选和开通按钮，支持跳转查看协议。
 * 关键数据结构：isAgreed（是否同意协议布尔值）、onVipOpen（开通回调函数）、
 * pageInfo（导航路由栈NavPathStack）。包含if逻辑：根据isAgreed判断是否允许开通（未勾选提示用户）。
 * @layout: 垂直布局。顶部为协议勾选行（复选框+协议文字，协议文字可点击跳转），
 * 底部为"立即开通"按钮（浅黄色背景，全宽）。整体居中显示。
 * @constraints: onVipOpen回调函数必须正确处理开通逻辑，pageInfo导航路由栈必须正确初始化，
 * 开通前必须勾选协议
 * @isGen: true
 * @fileType: component
 * @zhName: VIP开通组件
 * @subPage: ServiceAgreement
 */
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