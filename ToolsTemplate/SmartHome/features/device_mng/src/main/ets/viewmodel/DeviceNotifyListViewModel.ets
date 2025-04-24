import { AddedDeviceObserverIntf, AddedDevicesModel, DeviceNotifyRecord } from '../model/AddedDevicesModel';
import { intl } from '@kit.LocalizationKit';

export class DeviceMessageListRecordViewModel {
  message: string;
  day: string;
  week: string;
  hourMinute: string;

  constructor(record: DeviceNotifyRecord) {
    this.message = record.message;

    let dateFormat1 = new intl.DateTimeFormat('zh-CN', { dateStyle: 'short', timeStyle: 'medium' });
    let time = dateFormat1.format(record.date);
    this.day = time.split(' ')[0];
    this.hourMinute = time.split(' ')[1];

    let dateFormat2 = new intl.DateTimeFormat('zh-CN', { weekday: 'long' });
    this.week = dateFormat2.format(record.date);
  }
}

@ObservedV2
export class DeviceNotifyListViewModel extends AddedDeviceObserverIntf {
  deviceId: string = '';
  deviceName: string = '';
  deviceImage: ResourceStr = '';
  @Trace deviceMessageRecords: DeviceMessageListRecordViewModel[] = [];
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
    addedDeviceInfo.deviceNotifyRecords.forEach((item) => {
      this.deviceMessageRecords.unshift(new DeviceMessageListRecordViewModel(item));
    });
    this.deviceMngModel.registerAddedDeviceObserver(this.deviceId, this);
  }

  public setDeviceMessageRead() {
    this.deviceMngModel.setDeviceMessageRead(this.deviceId, true);
  }

  override OnDeviceNotifyRecordAdd(record: DeviceNotifyRecord): void {
    this.deviceMessageRecords.unshift(new DeviceMessageListRecordViewModel(record));
  }
}