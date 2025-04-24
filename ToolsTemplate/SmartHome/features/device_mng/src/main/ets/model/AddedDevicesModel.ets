import { AdapterModel, DeviceBaseInfo } from 'external_interactions';
import { MQTT_STATE, MqttClientModel, MqttClientObserverIntf } from './MqttClientModel';
import { MqttMessage } from '@ohos/mqtt';
import { prompt, ObserverMngModel } from 'utils';

export class DeviceNotifyRecord {
  message: string;
  date: Date;

  constructor(message: string, date: Date) {
    this.message = message;
    this.date = date;
  }
}

export interface AddDeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceUuid: string;
}

export interface AddedDeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceImage: ResourceStr;
  detailUrl: ResourceStr;
  briefUrl: ResourceStr;
  deviceLatestMessage: string;
  deviceNotifyRecords: DeviceNotifyRecord[];
  isDeviceNotifyRecordsRead: boolean;
  deviceLatestBriefStateText: string; /* 用于卡片显示 */
  isDeviceE2EConnected: boolean;
}

export class AddedDevicesObserverIntf {
  OnDeviceAdded(addedDeviceInfo: AddedDeviceInfo): void {
  }

  OnDeviceDeleted(deviceId: string): void {
  }
}

export class AddedDeviceObserverIntf {
  OnDeviceMessageReceive(deviceLatestMessage: string): void {
  }

  OnDeviceNameChange(deviceName: string): void {
  }

  OnDeviceNotifyRecordAdd(record: DeviceNotifyRecord): void {
  }

  OnDeviceNotifyIsReadChange(read: boolean): void {
  }

  OnDeviceLatestBriefStateTextChange(state: string): void {
  }

  OnIsDeviceE2EConnectedChange(isDeviceE2EConnected: boolean): void {
  }

  OnLocalMqttBrokerConnectStateChange(mqttState: MQTT_STATE): void {
  }

  OnDeviceDelete(): void {
  }
}

class AddedDevice extends ObserverMngModel<AddedDeviceObserverIntf> implements MqttClientObserverIntf {
  private deviceId: string;
  private deviceName: string;
  private deviceImage: ResourceStr;
  private detailUrl: ResourceStr;
  private briefUrl: ResourceStr;
  private deviceUuid: string;
  private mqttClient: MqttClientModel;
  private deviceLatestMessage: string = '';
  private deviceNotifyRecords: DeviceNotifyRecord[] = [];
  private isDeviceNotifyRecordsRead: boolean = true;
  private deviceLatestBriefStateText: string = '';
  private isDeviceMqttBrokerConnected: boolean = false;
  private isDeviceE2EConnected: boolean = false;
  private localMqttBrokerConnectState: MQTT_STATE = MQTT_STATE.INITIALIZE;

  constructor(id: string, name: string, deviceUuid: string, infoAboutView: DeviceBaseInfo) {
    super();
    this.deviceId = id;
    this.deviceName = name;
    this.deviceImage = infoAboutView.deviceImage;
    this.detailUrl = infoAboutView.detailUrl;
    this.briefUrl = infoAboutView.briefUrl;
    this.deviceUuid = deviceUuid;
    this.mqttClient = new MqttClientModel();
    this.mqttClient.registerObserver(this);
  }

  destructor() {
    this.observers.forEach((item) => {
      item.OnDeviceDelete();
    });
  }

  public setDeviceName(deviceName: string) {
    this.deviceName = deviceName;
    this.observers.forEach((item) => {
      item.OnDeviceNameChange(deviceName);
    });
  }

  public async publishTopic(topic: string, payload: string) {
    topic = topic.replace('$deviceUuid', this.deviceUuid);
    this.mqttClient.publishTopic(topic, payload);
  }

  public async subscribeTopic(topic: string) {
    topic = topic.replace('$deviceUuid', this.deviceUuid);
    this.mqttClient.subscribeTopic(topic);
  }

  OnMessageReceive(message: string, data: MqttMessage): void {
    data.topic = data.topic.replace(this.deviceUuid, '$deviceUuid');

    this.deviceLatestMessage = JSON.stringify(data);

    this.observers.forEach((item) => {
      item.OnDeviceMessageReceive(this.deviceLatestMessage);
    });
  }

  OnMqttStateChange(mqttState: MQTT_STATE): void {
    this.localMqttBrokerConnectState = mqttState;
    this.updateIsDeviceE2EConnected();
    this.observers.forEach((item) => {
      item.OnLocalMqttBrokerConnectStateChange(mqttState);
    });
  }

  public addMessageRecord(message: string) {
    let deviceMessageRecord = new DeviceNotifyRecord(message, new Date());
    this.deviceNotifyRecords.push(deviceMessageRecord);

    this.observers.forEach((item) => {
      item.OnDeviceNotifyRecordAdd(deviceMessageRecord);
    });

    this.setDeviceMessageRead(false);
  }

  public updateDeviceBriefStateText(state: string) {
    this.deviceLatestBriefStateText = state;
    this.observers.forEach((item) => {
      item.OnDeviceLatestBriefStateTextChange(state);
    });
  }

  public updateIsDeviceE2EConnected() {
    this.isDeviceE2EConnected = this.isDeviceMqttBrokerConnected &&
      (this.localMqttBrokerConnectState === MQTT_STATE.CONNECTED);
    this.observers.forEach((item) => {
      item.OnIsDeviceE2EConnectedChange(this.isDeviceE2EConnected);
    });
  }

  public updateIsDeviceMqttBrokerConnected(isDeviceConnected: boolean) {
    this.isDeviceMqttBrokerConnected = isDeviceConnected;
    this.updateIsDeviceE2EConnected();
  }

  public getAddedDeviceInfo(): AddedDeviceInfo {
    let addedDeviceInfo: AddedDeviceInfo = {
      deviceId: this.deviceId,
      deviceName: this.deviceName,
      deviceImage: this.deviceImage,
      detailUrl: this.detailUrl,
      briefUrl: this.briefUrl,
      deviceLatestMessage: this.deviceLatestMessage,
      deviceNotifyRecords: this.deviceNotifyRecords,
      isDeviceNotifyRecordsRead: this.isDeviceNotifyRecordsRead,
      deviceLatestBriefStateText: this.deviceLatestBriefStateText,
      isDeviceE2EConnected: this.isDeviceE2EConnected,
    };
    return addedDeviceInfo;
  }

  public setDeviceMessageRead(read: boolean) {
    this.isDeviceNotifyRecordsRead = read;
    this.observers.forEach((item) => {
      item.OnDeviceNotifyIsReadChange(read);
    });
  }
}

class AddedDevicesDataMng {
  private observers: AddedDevicesObserverIntf[] = [];
  private addedDevicesMng: Map<string, AddedDevice> = new Map<string, AddedDevice>();

  constructor(observers: AddedDevicesObserverIntf[]) {
    this.observers = observers;
  }

  public getDevice(id: string): AddedDevice | undefined {
    return this.addedDevicesMng.get(id);
  }

  public clear(): void {
    this.addedDevicesMng.clear();
  }

  public isExist(id: string): boolean {
    return this.addedDevicesMng.has(id);
  }

  public addDevice(id: string, info: AddedDevice): void {
    let device = this.getDevice(id);
    if (device !== undefined) {
      prompt('添加失败，设备已存在，请先删除');
      return
    }
    this.addedDevicesMng.set(id, info);
    this.observers.forEach((item) => {
      item.OnDeviceAdded(info.getAddedDeviceInfo());
    });
  }

  public deleteDevice(id: string): void {
    let device = this.getDevice(id);
    device?.destructor();

    this.addedDevicesMng.delete(id);
    this.observers.forEach((item) => {
      item.OnDeviceDeleted(id);
    });
  }

  public forEach(func: (info: AddedDevice) => void): void {
    this.addedDevicesMng.forEach(func);
  }
}

export class AddedDevicesModel extends ObserverMngModel<AddedDevicesObserverIntf> {
  private static instance: AddedDevicesModel;
  private addedDevicesMng: AddedDevicesDataMng = new AddedDevicesDataMng(this.observers);

  private constructor() {
    super();
  }

  static getInstance(): AddedDevicesModel {
    if (!AddedDevicesModel.instance) {
      AddedDevicesModel.instance = new AddedDevicesModel();
    }
    return AddedDevicesModel.instance;
  }

  public getAddedDevices(): AddedDeviceInfo[] {
    let addedDevices: AddedDeviceInfo[] = [];
    this.addedDevicesMng.forEach((item) => {
      addedDevices.push(item.getAddedDeviceInfo());
    });
    return addedDevices;
  }

  public addDevice(addDeviceInfo: AddDeviceInfo): void {
    let info = AdapterModel.getInstance().getDeviceInfo(addDeviceInfo.deviceName);
    let addedDeviceInfo = new AddedDevice(addDeviceInfo.deviceId, addDeviceInfo.deviceName, addDeviceInfo.deviceUuid,
      info.deviceInfo);

    this.addedDevicesMng.addDevice(addDeviceInfo.deviceId, addedDeviceInfo);
  }

  public getAddedDeviceInfo(deviceId: string): AddedDeviceInfo | undefined {
    let addedDevice = this.addedDevicesMng.getDevice(deviceId);
    if (addedDevice === undefined) {
      return undefined;
    }
    return addedDevice.getAddedDeviceInfo();
  }

  public deleteDevice(deviceId: string) {
    this.addedDevicesMng.deleteDevice(deviceId);
  }

  public addDeviceMessageRecord(deviceId: string, message: string) {
    let addedDevice = this.addedDevicesMng.getDevice(deviceId);
    if (addedDevice === undefined) {
      return;
    }
    addedDevice.addMessageRecord(message);
  }

  public updateDeviceBriefStateText(deviceId: string, message: string) {
    let addedDevice = this.addedDevicesMng.getDevice(deviceId);
    if (addedDevice === undefined) {
      return;
    }
    addedDevice.updateDeviceBriefStateText(message);
  }

  public updateDeviceMqttBrokerConnectState(deviceId: string, message: string) {
    let addedDevice = this.addedDevicesMng.getDevice(deviceId);
    if (addedDevice === undefined) {
      return;
    }
    addedDevice.updateIsDeviceMqttBrokerConnected(message === 'on');
  }

  public async publishTopic(deviceId: string, topic: string, payload: string) {
    let device = this.addedDevicesMng.getDevice(deviceId);
    if (device === undefined) {
      return;
    }
    device.publishTopic(topic, payload);
  }

  public async subscribeTopic(deviceId: string, topic: string) {
    let device = this.addedDevicesMng.getDevice(deviceId);
    if (device === undefined) {
      return;
    }
    device.subscribeTopic(topic);
  }

  public registerAddedDeviceObserver(deviceId: string, observer: AddedDeviceObserverIntf): void {
    let device = this.addedDevicesMng.getDevice(deviceId);
    if (device === undefined) {
      return;
    }
    device.registerObserver(observer);
  }

  public setDeviceName(deviceId: string, deviceName: string) {
    let device = this.addedDevicesMng.getDevice(deviceId);
    if (device === undefined) {
      return;
    }
    device.setDeviceName(deviceName);
  }

  public setDeviceMessageRead(deviceId: string, read: boolean) {
    let device = this.addedDevicesMng.getDevice(deviceId);
    if (device === undefined) {
      return;
    }
    device.setDeviceMessageRead(read);
  }

  private addDefaultDevice(deviceId: string, deviceName: string, deviceUuid: string) {
    let a = AdapterModel.getInstance().getDeviceInfo(deviceName);
    let addedDeviceInfo = new AddedDevice(deviceId, deviceName, deviceUuid, a.deviceInfo);
    this.addedDevicesMng.addDevice(deviceId, addedDeviceInfo);
  }
}