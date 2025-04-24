import { AddedDeviceObserverIntf, AddedDevicesModel } from '../model/AddedDevicesModel';

@ObservedV2
export class DeviceDetailViewModel extends AddedDeviceObserverIntf {
  deviceId: string = '';
  @Trace deviceName: string = '';
  @Trace deviceLatestMessage: string = '';
  deviceImage: ResourceStr = '';
  detailUrl: ResourceStr = '';
  @Trace isDeviceE2EConnected: boolean = false;
  private deviceMngModel: AddedDevicesModel = AddedDevicesModel.getInstance();

  constructor(deviceId: string) {
    super();
    let addedDeviceInfo = this.deviceMngModel.getAddedDeviceInfo(deviceId);
    if (addedDeviceInfo === undefined) {
      return;
    }
    this.deviceId = addedDeviceInfo.deviceId;
    this.deviceName = addedDeviceInfo.deviceName;
    this.deviceImage = addedDeviceInfo.deviceImage;
    this.detailUrl = addedDeviceInfo.detailUrl;
    this.deviceLatestMessage = addedDeviceInfo.deviceLatestMessage;
    this.isDeviceE2EConnected = addedDeviceInfo.isDeviceE2EConnected;
    this.deviceMngModel.registerAddedDeviceObserver(this.deviceId, this);
  }

  override OnDeviceMessageReceive(deviceLatestMessage: string): void {
    this.deviceLatestMessage = deviceLatestMessage;
  }

  override OnDeviceNameChange(deviceName: string): void {
    this.deviceName = deviceName;
  }

  override OnIsDeviceE2EConnectedChange(isDeviceE2EConnected: boolean): void {
    this.isDeviceE2EConnected = isDeviceE2EConnected;
  }

  deleteDevice() {
    this.deviceMngModel.deleteDevice(this.deviceId);
  }
}