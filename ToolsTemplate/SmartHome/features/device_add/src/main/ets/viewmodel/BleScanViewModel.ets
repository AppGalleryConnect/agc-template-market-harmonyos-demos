import { AdapterModel } from 'external_interactions';
import { ConnectionState } from 'utils';
import { BleClientModel,
  BleClientObserverIntf,
  BleDeviceInfo,
  ScannedDeviceObserverIntf } from '../model/BleClientModel';

export enum BLE_SCAN_STATE {
  INIT,
  SCANNING,
  SCANNED_SUCCESS,
  SCANNED_FAIL,
}

@ObservedV2
export class ScannedDeviceViewModel implements ScannedDeviceObserverIntf {
  deviceId: string;
  deviceName: string;
  deviceImage: ResourceStr;
  @Trace connectionState: number;
  @Trace isConnectVisible: boolean = true;
  @Trace isConnectingVisible: boolean = false;
  @Trace isConnectedVisible: boolean = false;
  private bleClientModel: BleClientModel = BleClientModel.getInstance();

  OnConnectionStateChange(connectionState: number): void {
    this.connectionState = connectionState;
    this.isConnectVisible = (this.connectionState === ConnectionState.STATE_DISCONNECTED);
    this.isConnectingVisible = (this.connectionState === ConnectionState.STATE_CONNECTING);
    this.isConnectedVisible = (this.connectionState === ConnectionState.STATE_CONNECTED);
  }

  constructor(bleDeviceInfo: BleDeviceInfo, image: ResourceStr) {
    this.deviceId = bleDeviceInfo.deviceId;
    this.deviceName = bleDeviceInfo.deviceName;
    this.connectionState = bleDeviceInfo.connectionState;
    this.deviceImage = image;
    this.bleClientModel.registerScannedDeviceObserver(this.deviceId, this)
  }
}

@ObservedV2
export class BleScanViewModel extends BleClientObserverIntf {
  @Trace devices: ScannedDeviceViewModel[] = [];
  @Trace scanState: BLE_SCAN_STATE = BLE_SCAN_STATE.INIT;
  deviceNamesToScan: string[] = [];
  private bleClientModel: BleClientModel = BleClientModel.getInstance();

  constructor(deviceNamesToScan?: string[]) {
    super()
    if (deviceNamesToScan) {
      this.deviceNamesToScan = deviceNamesToScan;
    }
    this.bleClientModel.registerObserver(this)
  }

  destructor(): void {
    this.bleClientModel.removeObserver(this)
  }

  override OnBleDeviceAdd(bleDeviceInfo: BleDeviceInfo): void {
    let image = AdapterModel.getInstance().getDeviceInfo(bleDeviceInfo.deviceName).deviceInfo.deviceImage
    let device = new ScannedDeviceViewModel(bleDeviceInfo, image);
    this.devices.push(device)
  }

  override OnBleDeviceDelete(deviceId: string): void {
    let index = this.devices.findIndex((item) => {
      return item.deviceId === deviceId
    })
    if (index === -1) {
      return
    }
    this.devices.splice(index, 1)
  }

  override OnBleScanStop(): void {
    if (this.devices.length === 0) {
      this.scanState = BLE_SCAN_STATE.SCANNED_FAIL
    } else {
      this.scanState = BLE_SCAN_STATE.SCANNED_SUCCESS
    }
  }

  public startBleScan(): void {
    this.bleClientModel.startBleScan(this.deviceNamesToScan)
    this.scanState = BLE_SCAN_STATE.SCANNING
  }

  public stopBleScan(): void {
    if (this.scanState === BLE_SCAN_STATE.SCANNING) {
      this.bleClientModel.stopBleScan()
    }
  }

  public connect(deviceId: string): void {
    this.bleClientModel.connect(deviceId)
  }
}