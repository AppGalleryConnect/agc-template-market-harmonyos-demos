import { routerStack, RouterMap } from 'lib_foundation'
import { PrivacyAgreementView } from 'module_privacy_agreement'
import { SetupUtil } from '../utils/SetupUtil'

@Builder
export function SafePageBuilder() {
  SafePage()
}

@ComponentV2
struct SafePage {
  @Local
  openSheet: boolean = false

  build() {
    NavDestination() {
      PrivacyAgreementView({
        appIcon: $r('app.media.app_icon'),
        appName: '综合商城模板',
        appDesc: '这是一个适用于网络购物的综合商城应用模板',
        stack: routerStack.getActiveStack(),
        handleConfirm: () => {
          if (SetupUtil.navInfo) {
            routerStack.replacePath({
              name: RouterMap.MAIN_ENTRY,
            })
          } else {
            routerStack.replacePath({
              name: RouterMap.SPLASH_PAGE,
            })
          }
        },
      })
    }
    .hideTitleBar(true)
  }
}
