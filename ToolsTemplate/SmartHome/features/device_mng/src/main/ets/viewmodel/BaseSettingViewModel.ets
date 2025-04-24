import { AddedDeviceObserverIntf, AddedDevicesModel } from '../model/AddedDevicesModel';

@ObservedV2
export class BaseSettingViewModel extends AddedDeviceObserverIntf {
  deviceId: string = '';
  @Trace deviceName: string = '';
  private deviceMngModel: AddedDevicesModel = AddedDevicesModel.getInstance();

  constructor(deviceId: string) {
    super();
    let addedDeviceInfo = this.deviceMngModel.getAddedDeviceInfo(deviceId);
    if (addedDeviceInfo === undefined) {
      return;
    }
    this.deviceId = addedDeviceInfo.deviceId;
    this.deviceName = addedDeviceInfo.deviceName;
    this.deviceMngModel.registerAddedDeviceObserver(this.deviceId, this);
  }

  override OnDeviceNameChange(deviceName: string): void {
    this.deviceName = deviceName;
  }

  setDeviceName(deviceName: string) {
    this.deviceMngModel.setDeviceName(this.deviceId, deviceName);
  }
}