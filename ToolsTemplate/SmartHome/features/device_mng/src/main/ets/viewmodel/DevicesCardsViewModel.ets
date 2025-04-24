import { AddedDeviceInfo, AddedDevicesModel, AddedDevicesObserverIntf } from '../model/AddedDevicesModel';
import { DeviceCardViewModel } from './DeviceCardViewModel';

@ObservedV2
export class DevicesCardsViewModel extends AddedDevicesObserverIntf {
  @Trace addedDevices: DeviceCardViewModel[] = [];
  @Trace addedDevicesId: string[] = [];
  private deviceMngModel: AddedDevicesModel = AddedDevicesModel.getInstance();

  constructor() {
    super();
    this.deviceMngModel.registerObserver(this);
    this.getAddedDevices();
  }

  destructor(): void {
    this.deviceMngModel.removeObserver(this);
  }

  override OnDeviceAdded(addedDeviceInfo: AddedDeviceInfo): void {
    this.addDevice(addedDeviceInfo);
  }

  override OnDeviceDeleted(deviceId: string): void {
    let index = this.addedDevices.findIndex((item) => {
      return item.deviceId === deviceId;
    });
    if (index === -1) {
      return;
    }
    this.addedDevices.splice(index, 1);
    this.addedDevicesId.splice(this.addedDevicesId.indexOf(deviceId), 1);
  }

  private addDevice(addedDeviceInfo: AddedDeviceInfo) {
    let device = new DeviceCardViewModel(addedDeviceInfo.deviceId);
    this.addedDevices.push(device);
    this.addedDevicesId.push(addedDeviceInfo.deviceId);
  }

  private getAddedDevices() {
    let addedDevices = this.deviceMngModel.getAddedDevices();
    addedDevices.forEach((item) => {
      this.addDevice(item);
    });
  }
}