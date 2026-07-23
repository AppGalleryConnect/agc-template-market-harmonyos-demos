import { PrivacyConsentUtils } from '../common/PrivacyConsentUtils';

@Builder
export function SafePageBuilder() {
  SafePage()
}

@ComponentV2
struct SafePage {
  @Local controller: PrivacyConsentUtils = new PrivacyConsentUtils(this.getUIContext());

  aboutToAppear(): void {
    this.controller.openFullScreenDialog();
  }

  build() {
    NavDestination() {
    }
    .hideTitleBar(true)
  }
}
