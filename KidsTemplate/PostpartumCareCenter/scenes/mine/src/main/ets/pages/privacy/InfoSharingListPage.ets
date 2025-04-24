@Builder
export function InfoSharingListPageBuilder() {
  InfoSharingListPage();
}

@ComponentV2
@Preview
export struct InfoSharingListPage {
  build() {
    NavDestination() {
      Text('请根据相关隐私政策添加第三方信息共享清单')
    }
  }
}