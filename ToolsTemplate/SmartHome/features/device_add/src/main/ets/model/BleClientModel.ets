import { access, ble, constant } from '@kit.ConnectivityKit';
import { ObserverMngModel } from 'utils';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { ConnectionState, LogUtil } from 'utils';

export interface BleDeviceInfo {
  deviceId: string;
  deviceName: string;
  connectionState: number;
  deviceUuid: string;
}

export interface ScannedDeviceObserverIntf {
  OnConnectionStateChange(connectionState: number): void;
}

const TAG = 'BleClient';

class ScannedDevice extends ObserverMngModel<ScannedDeviceObserverIntf> {
  private deviceId: string;
  private deviceName: string;
  private connectionState: number = ConnectionState.STATE_DISCONNECTED;
  private deviceUuid: string = '';

  private mGattClientDevice: ble.GattClientDevice | null = null;
  private wifiCharacteristic: ble.BLECharacteristic | undefined = undefined;
  private deviceUuidCharacteristic: ble.BLECharacteristic | undefined = undefined;

  constructor(id: string, name: string) {
    super()
    this.deviceId = id;
    this.deviceName = name;
  }

  destructor() {
    this.disconnect()
  }

  private writeCharacteristicValueCb(err: BusinessError) {
    if (err) {
      console.info('notifyCharacteristicChanged callback failed');
    } else {
      console.info('notifyCharacteristicChanged callback successful');
    }
  }

  private arrayBufferToString(buffer: ArrayBuffer): string {
    let decoder = new util.TextDecoder();
    return decoder.decodeToString(new Uint8Array(buffer))
  }

  private stringToArrayBuffer(str: string): ArrayBuffer {
    let encoder = new util.TextEncoder();
    const uint8Array = encoder.encodeInto(str)
    return uint8Array.buffer;
  }

  private readDeviceUuidCb = (code: BusinessError, bleCharacteristic: ble.BLECharacteristic) => {
    if (code != null) {
      return;
    }
    this.deviceUuid = this.arrayBufferToString(bleCharacteristic.characteristicValue)
  }

  private readDeviceUuid() {
    this.mGattClientDevice?.readCharacteristicValue(this.deviceUuidCharacteristic, this.readDeviceUuidCb)
  }

  setWifi(wifiName: string, wifiPassword: string) {
    if (this.wifiCharacteristic === undefined) {
      return
    }
    let wifi = wifiName + '/' + wifiPassword

    this.wifiCharacteristic.characteristicValue = this.stringToArrayBuffer(wifi)

    this.mGattClientDevice?.writeCharacteristicValue(this.wifiCharacteristic, ble.GattWriteType.WRITE,
                                                     this.writeCharacteristicValueCb)
  }

  private getCharacteristic(services: Array<ble.GattService>, serviceUuid: string, characteristicUuid: string):
                                          ble.BLECharacteristic | undefined {
    let service: ble.GattService | undefined = services?.find(item => item.serviceUuid === serviceUuid)
    if (service === undefined) {
      return undefined
    }
    let characteristic: ble.BLECharacteristic | undefined =
      service.characteristics.find(item => item.characteristicUuid === characteristicUuid);
    return characteristic
  }

  private serviceUuid: string = '0000180D-0000-1000-8000-00805F9B34FB'
  private wifiCharacteristicUuid: string = '00002A37-0000-1000-8000-00805F9B34FB'
  private deviceUuidCharacteristicUuid: string = '00002A38-0000-1000-8000-00805F9B34FB'
  descriptorUuid: string = '00002902-0000-1000-8000-00805F9B34FB'

  private setConnectionState(connectionState: number) {
    this.connectionState = connectionState;
    this.observers.forEach((item) => {
      item.OnConnectionStateChange(connectionState);
    })
  }

  private BLEConnectionStateChangeFunc = async (data: ble.BLEConnectionChangeState): Promise<void> => {
    let state: constant.ProfileConnectionState = data.state;
    if (data) {
      if (state === constant.ProfileConnectionState.STATE_CONNECTED) {
        this.setConnectionState(ConnectionState.STATE_CONNECTED)

        let services: Array<ble.GattService> | undefined = await this.mGattClientDevice?.getServices();
        if (services === undefined) {
          return
        }
        let wifiCharacteristic: ble.BLECharacteristic | undefined = this.getCharacteristic(services, this.serviceUuid,
                                                                        this.wifiCharacteristicUuid)
        let deviceUuidCharacteristic: ble.BLECharacteristic | undefined = this.getCharacteristic(services,
                                                                this.serviceUuid, this.deviceUuidCharacteristicUuid)

        this.wifiCharacteristic = wifiCharacteristic
        this.deviceUuidCharacteristic = deviceUuidCharacteristic

        this.readDeviceUuid()
      } else if (state === constant.ProfileConnectionState.STATE_DISCONNECTED) {
        this.setConnectionState(ConnectionState.STATE_DISCONNECTED)
      }
    }
  }

  private onBLEConnectionStateChange() {
    this.mGattClientDevice?.on('BLEConnectionStateChange', this.BLEConnectionStateChangeFunc);
  }

  private offBLEConnectionStateChange() {
    this.mGattClientDevice?.off('BLEConnectionStateChange');
  }

  private BLECharacteristicChangeFunc = (data: ble.BLECharacteristic): void => {
    AppStorage.setOrCreate('heartRate', 1);
  }

  private onBLECharacteristicChange() {
    this.mGattClientDevice?.on('BLECharacteristicChange', this.BLECharacteristicChangeFunc);
  }

  private offBLECharacteristicChange() {
    this.mGattClientDevice?.off('BLECharacteristicChange');
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  private onBLEChange() {
    this.onBLEConnectionStateChange();
    this.onBLECharacteristicChange();
  }

  private offBLEChange() {
    this.offBLEConnectionStateChange();
    this.offBLECharacteristicChange();
  }

  private disconnect() {
    try {
      this.offBLEChange();
      if (this.connectionState === ConnectionState.STATE_CONNECTED) {
        this.mGattClientDevice?.disconnect()
      }
      this.mGattClientDevice?.close();
      this.mGattClientDevice = null;
      this.setConnectionState(ConnectionState.STATE_DISCONNECTED)
    } catch (err) {
      LogUtil.error(TAG, 'Fail to disconnect');
    }
  }

  connect() {
    this.mGattClientDevice = ble.createGattClientDevice(this.deviceId);
    try {
      this.onBLEChange()
      this.setConnectionState(ConnectionState.STATE_CONNECTING)
      this.delay(500).then(() => {
        this.mGattClientDevice?.connect()
      })
    } catch (err) {
      LogUtil.error(TAG, 'Fail to connect');
    }
  }

  public getBleDeviceInfo(): BleDeviceInfo {
    let bleDeviceInfo: BleDeviceInfo = {
      deviceId: this.deviceId,
      deviceName: this.deviceName,
      connectionState: this.connectionState,
      deviceUuid: this.deviceUuid,
    }
    return bleDeviceInfo
  }
}

class ScannedDevicesDataMng {
  private observers: BleClientObserverIntf[] = []

  constructor(observers: BleClientObserverIntf[]) {
    this.observers = observers
  }

  private scannedDevicesMng: Map<string, ScannedDevice> = new Map<string, ScannedDevice>();

  public getDevice(id: string): ScannedDevice | undefined {
    return this.scannedDevicesMng.get(id);
  }

  public clear(): void {
    for (let key of this.scannedDevicesMng.keys()) {
      this.deleteDevice(key)
    }
  }

  public isExist(id: string): boolean {
    return this.scannedDevicesMng.has(id);
  }

  public deleteDevice(id: string): void {
    this.observers.forEach((item) => {
      item.OnBleDeviceDelete(id);
    })
    let info = this.getDevice(id)
    info?.destructor()
    this.scannedDevicesMng.delete(id)
  }

  public addDevice(id: string, info: ScannedDevice): void {
    this.scannedDevicesMng.set(id, info)
    this.observers.forEach((item) => {
      item.OnBleDeviceAdd(info.getBleDeviceInfo());
    })
  }
}

export class BleClientObserverIntf {
  OnBleDeviceAdd(bleDeviceInfo: BleDeviceInfo): void {}
  OnBleDeviceDelete(deviceId: string): void {}
  OnBleDeviceSetComplete(bleDeviceInfo: BleDeviceInfo): void {}
  OnBleScanStop(): void {}
}

export class BleClientModel extends ObserverMngModel<BleClientObserverIntf> {
  private scannedDevicesMng: ScannedDevicesDataMng = new ScannedDevicesDataMng(this.observers);
  private static instance: BleClientModel;
  private mTimeoutID: number = -1;
  private scanTimeMs: number = 10000;
  private deviceNamesToScan: string[] = [];


  public getBleDeviceInfo(deviceId: string): BleDeviceInfo | undefined {
    let scannedDeviceInfo =  this.scannedDevicesMng.getDevice(deviceId);
    if (scannedDeviceInfo === undefined) {
      return undefined
    }
    return scannedDeviceInfo.getBleDeviceInfo()
  }

  private constructor() { super() }

  static getInstance(): BleClientModel {
    if (!BleClientModel.instance) {
      BleClientModel.instance = new BleClientModel();
    }
    return BleClientModel.instance;
  }

  private OnBluetoothStateChange(data: access.BluetoothState) {
    if (data === access.BluetoothState.STATE_ON) {
      this.startBleScanInner();
    } else if (data === access.BluetoothState.STATE_OFF) {
      this.scannedDevicesMng.clear()
    }
  }

  private isScannedDeviceExist(id: string): boolean {
    return this.scannedDevicesMng.isExist(id);
  }

  private addScannedDevice(id: string, name: string): void {
    let scannedDevice = new ScannedDevice(id, name);
    this.scannedDevicesMng.addDevice(id, scannedDevice);
  }

  private OnBleDeviceFind = (arr: Array<ble.ScanResult>) => {
    arr.forEach((item) => {
      let id: string = item.deviceId;
      let name: string = item.deviceName;
      if (this.isScannedDeviceExist(id) || name === '') {
        return
      }
      this.addScannedDevice(id, name)
    })
  }

  private isBluetoothEnabled(): boolean {
    const state: access.BluetoothState = access.getState();
    return state === access.BluetoothState.STATE_ON ||
           state === access.BluetoothState.STATE_TURNING_ON;
  }

  private enableBluetooth() {
    try {
      access.on('stateChange', this.OnBluetoothStateChange);
      access.enableBluetooth();
    } catch (err) {
    }
  }

  private clearScannedDevices() {
    this.scannedDevicesMng.clear()
  }

  private onBLEDeviceFind() {
    ble.on('BLEDeviceFind', this.OnBleDeviceFind);
  }

  private offBLEDeviceFind() {
    ble.off('BLEDeviceFind');
  }

  private startBleScanInner() {
    clearTimeout(this.mTimeoutID);
    this.clearScannedDevices()
    this.onBLEDeviceFind()

    let scanFilters: ble.ScanFilter[] = [];
    this.deviceNamesToScan.forEach((item) => {
      scanFilters.push({ name: item});
    });
    let scanOptions: ble.ScanOptions = {
      interval: 0,
      dutyMode: ble.ScanDuty.SCAN_MODE_LOW_POWER,
      matchMode: ble.MatchMode.MATCH_MODE_AGGRESSIVE
    }
    ble.startBLEScan((scanFilters.length === 0 ? null : scanFilters), scanOptions);
    this.mTimeoutID = setTimeout(() => {
      this.stopBleScan()
    }, this.scanTimeMs)
  }

  private stopBleScanInner() {
    clearTimeout(this.mTimeoutID);
    this.offBLEDeviceFind()
    ble.stopBLEScan();
  }

  readDeviceUuidCb(code: BusinessError, bleCharacteristic: ble.BLECharacteristic) {
    if (code != null) {
      return;
    }
    console.info('bluetooth characteristic uuid: ' + bleCharacteristic.characteristicUuid);
    let value = new Uint8Array(bleCharacteristic.characteristicValue);
    console.info('bluetooth characteristic value: ' + value[0] +','+ value[1]+','+ value[2]+','+ value[3]);
  }

  connect(deviceId: string) {
    let scannedDeviceInfo =  this.scannedDevicesMng.getDevice(deviceId);
    if (scannedDeviceInfo === undefined) {
      return
    }
    scannedDeviceInfo.connect()
  }

  public setWifi(deviceId: string, wifiName: string, wifiPassword: string) {
    let scannedDeviceInfo =  this.scannedDevicesMng.getDevice(deviceId);
    if (scannedDeviceInfo === undefined) {
      return
    }
    scannedDeviceInfo.setWifi(wifiName, wifiPassword)
  }

  public registerScannedDeviceObserver(deviceId: string, observer: ScannedDeviceObserverIntf): void {
    let scannedDeviceInfo =  this.scannedDevicesMng.getDevice(deviceId);
    if (scannedDeviceInfo === undefined) {
      return
    }
    scannedDeviceInfo.registerObserver(observer)
  }

  public setComplete(deviceId: string) {
    let scannedDeviceInfo =  this.scannedDevicesMng.getDevice(deviceId);
    if (scannedDeviceInfo === undefined) {
      return
    }
    this.observers.forEach((item) => {
      item.OnBleDeviceSetComplete(scannedDeviceInfo!.getBleDeviceInfo());
    })
  }

  public startBleScan(deviceNamesToScan: string[]): void {
    this.deviceNamesToScan = deviceNamesToScan
    if (!this.isBluetoothEnabled()) {
      this.enableBluetooth()
      return
    }
    this.startBleScanInner()
  }

  public stopBleScan(): void {
    this.deviceNamesToScan = []
    this.stopBleScanInner()
    this.observers.forEach((item) => {
      item.OnBleScanStop();
    })
  }
}