import { CourseApi, SignCodeState } from 'network';
import { geoLocationManager } from '@kit.LocationKit';
import { Permissions } from '@kit.AbilityKit';
import { PermissionUtil } from 'commonlib';
import { promptAction } from '@kit.ArkUI';

export enum SignState {
  INIT,
  SUCCESS,
  FAILED,
}

@ObservedV2
export class ClassSignInVM {
  private static _instance: ClassSignInVM;

  public static get instance() {
    if (!ClassSignInVM._instance) {
      ClassSignInVM._instance = new ClassSignInVM();
    }
    return ClassSignInVM._instance;
  }

  @Trace isSignLoading: boolean = false;
  @Trace hasLocationPermission: boolean = true;
  @Trace signState: SignState = SignState.INIT;
  @Trace verifyCourseName: string = '';

  // 获取位置授权
  public requestLocationPermission() {
    const permissions: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION'];
    PermissionUtil.requestPermissions(permissions,
      () => {
        this.hasLocationPermission = true;
      },
      () => {
        this.hasLocationPermission = false;
        promptAction.showToast({
          message: '需要开启定位权限用于上课签到功能',
        });
      });
  }

  public async classSignIn(code: string): Promise<void> {
    this.isSignLoading = true;
    // 获取当前经纬度，上传定位
    const locationRequest: geoLocationManager.CurrentLocationRequest = {
      priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
      timeoutMs: 10000,
    };
    const locationInfo = await geoLocationManager.getCurrentLocation(locationRequest);
    const resp = await CourseApi.signIn({
      latitude: locationInfo.latitude,
      longitude: locationInfo.longitude,
      signCode: code,
    });

    this.isSignLoading = false;
    this.signState = resp.data.signState === SignCodeState.SUCCESS ? SignState.SUCCESS : SignState.FAILED;
    this.verifyCourseName = resp.data.courseName;
  }

  public resetState() {
    this.isSignLoading = false;
    this.signState = SignState.INIT;
    this.verifyCourseName = '';
  }
}