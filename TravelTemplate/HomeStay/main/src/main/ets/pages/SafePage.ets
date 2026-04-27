import { PrivacyAgreementView } from './PrivacyAgreementView';

@Builder
export function SafePageBuilder() {
  SafePage();
}

@ComponentV2
struct SafePage {
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      PrivacyAgreementView({
        appIcon: $r('app.media.icon'),
        appName: '民宿模板',
        appDesc: '这是一个适用于民宿的应用模板',
        stack: this.mainPathStack,
        handleConfirm: () => {
          this.mainPathStack.replacePathByName('Main', null);
        },
      });
    }
    .hideTitleBar(true);
  }
}
