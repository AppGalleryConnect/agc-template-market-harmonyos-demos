
import deviceInfo from '@ohos.deviceInfo';

export class DeviceUtil {
  public static isTablet(): boolean {
    return deviceInfo.deviceType === 'tablet';
  }

  public static isPC(): boolean {
    return deviceInfo.deviceType === '2in1';
  }

  public static isPhone(): boolean {
    return deviceInfo.deviceType === 'phone';
  }
}