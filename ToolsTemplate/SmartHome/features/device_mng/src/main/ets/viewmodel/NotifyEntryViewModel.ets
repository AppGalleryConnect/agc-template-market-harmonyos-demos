import {
  AddedDeviceInfo,
  AddedDeviceObserverIntf,
  AddedDevicesModel,
  AddedDevicesObserverIntf,
} from '../model/AddedDevicesModel';

export class IsDeviceNotifyReadViewModel extends AddedDeviceObserverIntf {
  deviceId: string;
  isDeviceNotifyRecordsRead: boolean;
  callback: () => void;
  private deviceMngModel: AddedDevicesModel = AddedDevicesModel.getInstance();

  constructor(addedDeviceInfo: AddedDeviceInfo, callback: () => void) {
    super();
    this.deviceId = addedDeviceInfo.deviceId;
    this.isDeviceNotifyRecordsRead = addedDeviceInfo.isDeviceNotifyRecordsRead;
    this.callback = callback;

    this.deviceMngModel.registerAddedDeviceObserver(this.deviceId, this);
  }

  OnDeviceNotifyIsReadChange(read: boolean): void {
    this.isDeviceNotifyRecordsRead = read;
    this.callback();
  }
}

@ObservedV2
export class NotifyEntryViewModel extends AddedDevicesObserverIntf {
  @Trace isDevicesNotifyRecordsRead: boolean = true;
  addedDevices: IsDeviceNotifyReadViewModel[] = [];
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
    this.addedDevices.splice(index, 1);

    this.calcIsRead();
  }

  private calcIsRead() {
    let read: boolean = true;
    this.addedDevices.forEach((item) => {
      if (!item.isDeviceNotifyRecordsRead) {
        read = false;
      }
    });
    if (this.isDevicesNotifyRecordsRead !== read) {
      this.isDevicesNotifyRecordsRead = read;
    }
  }

  private addDevice(addedDeviceInfo: AddedDeviceInfo) {
    let device = new IsDeviceNotifyReadViewModel(addedDeviceInfo, () => {
      this.calcIsRead();
    });
    this.addedDevices.push(device);

    this.calcIsRead();
  }

  private getAddedDevices() {
    let addedDevices = this.deviceMngModel.getAddedDevices();
    addedDevices.forEach((item) => {
      this.addDevice(item);
    });
  }
}