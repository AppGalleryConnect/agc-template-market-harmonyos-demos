import { UserInfoForm } from './UserInfoForm';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';

@Builder
export function UserInfoBuilder() {
  UserInfoPage();
}

@ComponentV2
export struct UserInfoPage {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private hostContext: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  private isPcLayout(): boolean {
    try {
      const type = this.hostContext.resourceManager.getDeviceCapabilitySync().deviceType;
      return type === resourceManager.DeviceType.DEVICE_TYPE_2IN1;
    } catch (_e) {
      return false;
    }
  }

  build() {
    NavDestination() {
      UserInfoForm();
    }
    .title('个人信息')
    .hideTitleBar(this.isPcLayout())
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}
