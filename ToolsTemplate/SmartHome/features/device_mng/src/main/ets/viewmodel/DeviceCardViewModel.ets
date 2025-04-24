import { AddedDeviceObserverIntf, AddedDevicesModel } from '../model/AddedDevicesModel';
import { MQTT_STATE } from '../model/MqttClientModel';

@ObservedV2
export class DeviceCardViewModel extends AddedDeviceObserverIntf {
  deviceId: string = '';
  @Trace deviceName: string = '';
  @Trace deviceLatestMessage: string = '';
  deviceImage: ResourceStr = '';
  briefUrl: ResourceStr = '';
  @Trace deviceLatestBriefStateText: string = '';
  @Trace isDeviceE2EConnected: boolean = false;
  @Trace isLocalMqttBrokerConnected: boolean = false;
  @Trace isDeleted: boolean = false;
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
    this.briefUrl = addedDeviceInfo.briefUrl;
    this.deviceLatestMessage = addedDeviceInfo.deviceLatestMessage;
    this.deviceLatestBriefStateText = addedDeviceInfo.deviceLatestBriefStateText;
    this.isDeviceE2EConnected = addedDeviceInfo.isDeviceE2EConnected;

    this.deviceMngModel.registerAddedDeviceObserver(this.deviceId, this);
  }

  override OnDeviceMessageReceive(deviceLatestMessage: string): void {
    this.deviceLatestMessage = deviceLatestMessage;
  }

  override OnDeviceNameChange(deviceName: string): void {
    this.deviceName = deviceName;
  }

  override OnDeviceLatestBriefStateTextChange(state: string): void {
    this.deviceLatestBriefStateText = state;
  }

  OnIsDeviceE2EConnectedChange(isDeviceE2EConnected: boolean): void {
    if (this.isDeviceE2EConnected !== isDeviceE2EConnected) {
      this.isDeviceE2EConnected = isDeviceE2EConnected;
    }
  }

  override OnLocalMqttBrokerConnectStateChange(mqttState: MQTT_STATE): void {
    let isConnected = (mqttState === MQTT_STATE.CONNECTED);
    if (this.isLocalMqttBrokerConnected !== isConnected) {
      this.isLocalMqttBrokerConnected = isConnected;
    }
  }

  override OnDeviceDelete(): void {
    this.isDeleted = true;
  }
}
