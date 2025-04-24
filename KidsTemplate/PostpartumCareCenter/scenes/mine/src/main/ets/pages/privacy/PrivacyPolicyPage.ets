@Builder
export function PrivacyPolicyPageBuilder() {
  PrivacyPolicyPage();
}

@ComponentV2
export struct PrivacyPolicyPage {

  build() {
    NavDestination() {
      Text('请根据相关隐私政策添加隐私政策信息')
    }
  }
}