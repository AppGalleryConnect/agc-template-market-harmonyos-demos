import { BenefitPage } from './BenefitPage'

@Builder
export function vipBenefitPageBuilder() {
  VipBenefitPage()
}

@ComponentV2
struct VipBenefitPage {

  build() {
    NavDestination() {
      BenefitPage({
        isTabPage: false
      })
    }
    .hideTitleBar(true)
  }
}