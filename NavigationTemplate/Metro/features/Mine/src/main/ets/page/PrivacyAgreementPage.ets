import { MainEntryVM } from 'commonlib';
import { BaseTitle } from 'componentlib';

@Builder
export function PrivacyAgreementPageBuilder(name: string, param: Object) {
  PrivacyAgreementPage()
}

@Component
export struct PrivacyAgreementPage {
  vm: MainEntryVM = MainEntryVM.instance;
  @State title1: string = '隐私协议'
  @State title2: string = 'XX地铁官方APP隐私协议'

  @Builder
  MoreNewsBuilder() {
    Text(this.title1)
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    NavDestination() {
      BaseTitle({
        customTitle: () => {
          this.MoreNewsBuilder()
        },
        showBackBtn: true,
        onBack: () => {
          this.vm.navStack.pop()
        },
      });
      Scroll() {
        Column({ space: 20 }) {
          Text(this.title2)
            .fontWeight(FontWeight.Bold)
            .fontSize(16)
          Text($r('app.string.privacy_agreement'))
        }
        .padding({ left: 12, right: 12 })
        .backgroundColor(Color.White)
      }
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .width('100%')
  }
}

