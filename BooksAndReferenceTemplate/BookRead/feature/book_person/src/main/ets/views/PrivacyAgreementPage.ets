import { PrivacyAgreementView, PreferenceUtils } from 'module_privacy_agreement'
import { preferences } from '@kit.ArkData'
import { Constants } from 'common'

@ComponentV2
export struct PrivacyAgreementPage {
  @Local stack: NavPathStack = new NavPathStack()
  @Provider('isShow') isShow: boolean = false

  build() {
    NavDestination() {
      PrivacyAgreementView({
        appIcon: $r('app.media.app_icon'), // 使用时替换为应用图标
        appName: '阅读听书',
        appDesc: '业务描述',
        stack: this.stack,
        themeColor: '#E84026',
        handleConfirm: () => {
          this.stack.replacePath({
            name: Constants.LAUNCH_AD_ROUTER,
          })
        },
      })
    }
    .hideTitleBar(true)
    .onVisibleAreaChange([0.0], (isExpanding: boolean, currentRatio: number) => {
      if (isExpanding && currentRatio >= 0.0) {
        let isAgree = PreferenceUtils.getInstance().get('isAgreePrivacy') as boolean;
        if (!isAgree) {
          this.isShow = true
        }
      }
    })
    .onReady((context) => {
      this.stack = context.pathStack
    })
  }
}