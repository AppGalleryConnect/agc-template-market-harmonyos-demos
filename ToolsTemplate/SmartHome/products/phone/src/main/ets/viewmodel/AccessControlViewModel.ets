import { checkPermissionGrant } from 'utils';
import { abilityAccessCtrl } from '@kit.AbilityKit';

@ObservedV2
export class AccessControlViewModel {
  private static instance: AccessControlViewModel;
  @Trace bluetoothAccess: boolean = false;

  private constructor() {
    this.getAccess();
  }

  static getInstance(): AccessControlViewModel {
    if (!AccessControlViewModel.instance) {
      AccessControlViewModel.instance = new AccessControlViewModel();
    }
    return AccessControlViewModel.instance;
  }

  public async getAccess() {
    this.bluetoothAccess = await checkPermissionGrant('ohos.permission.ACCESS_BLUETOOTH') ===
    abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }
}