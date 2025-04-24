@Builder
export function PersonalInfoCollectListPageBuilder() {
  PersonalInfoCollectListPage();
}

@ComponentV2
export struct PersonalInfoCollectListPage {
  build() {
    NavDestination() {
      Text('请根据相关隐私政策添加个人信息收集清单')
    }
  }
}