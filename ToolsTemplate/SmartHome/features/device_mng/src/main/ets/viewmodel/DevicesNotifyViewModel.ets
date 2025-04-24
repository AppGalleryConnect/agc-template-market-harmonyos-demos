import {
  AddedDeviceInfo,
  AddedDeviceObserverIntf,
  AddedDevicesModel,
  DeviceNotifyRecord,
} from '../model/AddedDevicesModel';
import { intl } from '@kit.LocalizationKit';


export class DeviceNotifyRecordViewModel {
  message: string;
  time: string;

  constructor(record: DeviceNotifyRecord) {
    this.message = record.message;
    let dateFormat = new intl.DateTimeFormat('zh-CN', { dateStyle: 'short', timeStyle: 'medium' });
    this.time = dateFormat.format(record.date);
  }
}

@ObservedV2
export class DeviceNotifyViewModel extends AddedDeviceObserverIntf {
  deviceId: string;
  deviceName: string;
  deviceImage: ResourceStr;
  @Trace deviceLatestNotifyRecord: DeviceNotifyRecordViewModel | undefined = undefined;
  @Trace isDeviceNotifyRecordsRead: boolean;
  private deviceMngModel: AddedDevicesModel = AddedDevicesModel.getInstance();

  constructor(addedDeviceInfo: AddedDeviceInfo) {
    super();
    this.deviceId = addedDeviceInfo.deviceId;
    this.deviceName = addedDeviceInfo.deviceName;
    this.deviceImage = addedDeviceInfo.deviceImage;

    if (addedDeviceInfo.deviceNotifyRecords.length !== 0) {
      this.deviceLatestNotifyRecord = new DeviceNotifyRecordViewModel(addedDeviceInfo.deviceNotifyRecords.slice(-1)[0]);
    }
    this.isDeviceNotifyRecordsRead = addedDeviceInfo.isDeviceNotifyRecordsRead;
    this.deviceMngModel.registerAddedDeviceObserver(this.deviceId, this);
  }

  override OnDeviceNotifyRecordAdd(record: DeviceNotifyRecord): void {
    this.deviceLatestNotifyRecord = new DeviceNotifyRecordViewModel(record);
  }

  override OnDeviceNotifyIsReadChange(read: boolean): void {
    this.isDeviceNotifyRecordsRead = read;
  }
}

@ObservedV2
export class DevicesNotifyViewModel {
  @Trace addedDevices: DeviceNotifyViewModel[] = [];
  private deviceMngModel: AddedDevicesModel = AddedDevicesModel.getInstance();

  constructor() {
    this.getAddedDevices();
  }

  private addDevice(addedDeviceInfo: AddedDeviceInfo) {
    let device = new DeviceNotifyViewModel(addedDeviceInfo);
    this.addedDevices.push(device);
  }

  private getAddedDevices() {
    let addedDevices = this.deviceMngModel.getAddedDevices();
    addedDevices.forEach((item) => {
      this.addDevice(item);
    });
  }
}