import { BleClientModel, BleClientObserverIntf, BleDeviceInfo } from 'device_add';
import { AddDeviceInfo, AddedDevicesModel } from 'device_mng';

export class HomeViewModel extends BleClientObserverIntf {
  private bleClientModel: BleClientModel = BleClientModel.getInstance();
  private deviceMngModel: AddedDevicesModel = AddedDevicesModel.getInstance();

  constructor() {
    super();
    this.bleClientModel.registerObserver(this);
  }

  OnBleDeviceSetComplete(bleDeviceInfo: BleDeviceInfo): void {
    let addDeviceInfo: AddDeviceInfo = {
      deviceId: bleDeviceInfo.deviceId,
      deviceName: bleDeviceInfo.deviceName,
      deviceUuid: bleDeviceInfo.deviceUuid,
    };
    this.deviceMngModel.addDevice(addDeviceInfo);
  }
}
