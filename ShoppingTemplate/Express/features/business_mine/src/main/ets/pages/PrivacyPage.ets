import { PrivacyVM } from '../viewModels/PrivacyVM'

@Builder
export function PrivacyPageBuilder() {
  PrivacyPage()
}

@ComponentV2
struct PrivacyPage {
  vm: PrivacyVM = PrivacyVM.instance

  build() {
    NavDestination() {
      Column() {
        Text(this.vm.text)
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
      .padding({ top: 8, left: 16, right: 16 })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('协议')
    .onShown(() => {
      this.vm.init()
    })
  }
}