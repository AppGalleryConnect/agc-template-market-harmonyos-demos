/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { access, ble, connection, constant } from '@kit.ConnectivityKit';
import ArrayBufferUtils from './ArrayBufferUtils';
import { LogUtil } from './LogUtil';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';

const TAG = 'BleServer';

@ObservedV2
export class BleServerModel {
  @Trace bleState: string = '';
  @Trace wifiName: string = '';
  @Trace wifiPassword: string = '';
  @Trace wifi: string = '';
  deviceUuid: string = '';
  @Trace service: ble.GattService;
  serviceUuid: string = '0000180D-0000-1000-8000-00805F9B34FB';
  wifiCharacteristicUuid: string = '00002A37-0000-1000-8000-00805F9B34FB';
  deviceUuidCharacteristicUuid: string = '00002A38-0000-1000-8000-00805F9B34FB';
  descriptorUuid: string = '00002902-0000-1000-8000-00805F9B34FB';
  private mGattServer: ble.GattServer = ble.createGattServer();

  constructor(deviceUuid: string) {
    this.deviceUuid = deviceUuid;
    this.service = this.buildService();
    if (!this.mGattServer) {
      return;
    }
    this.addService();
    this.registerCallback();
  }

  arrayBufferToString(buffer: ArrayBuffer): string {
    let decoder = new util.TextDecoder();
    return decoder.decodeToString(new Uint8Array(buffer));
  }

  WriteCharacteristicReq = (characteristicWriteRequest: ble.CharacteristicWriteRequest) => {
    if (characteristicWriteRequest.serviceUuid === this.serviceUuid &&
      characteristicWriteRequest.characteristicUuid === this.wifiCharacteristicUuid) {
      this.WriteWifiCharacteristicReq(characteristicWriteRequest);
    }
  }

  WriteWifiCharacteristicReq(characteristicWriteRequest: ble.CharacteristicWriteRequest) {
    let deviceId: string = characteristicWriteRequest.deviceId;
    let transId: number = characteristicWriteRequest.transId;
    let offset: number = characteristicWriteRequest.offset;
    this.wifi = this.arrayBufferToString(characteristicWriteRequest.value);
    let arrayBufferCCC = new ArrayBuffer(8);
    let cccValue = new Uint8Array(arrayBufferCCC);
    cccValue[0] = 12;
    let serverResponse: ble.ServerResponse = {
      deviceId: deviceId,
      transId: transId,
      status: 0,
      offset: offset,
      value: arrayBufferCCC,
    };

    try {
      this.mGattServer.sendResponse(serverResponse);
    } catch (err) {
      console.error('errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  isBluetoothEnabled(): boolean {
    const state: access.BluetoothState = access.getState();
    LogUtil.info(`isBluetoothEnabled: state = ${state}`);
    if (state === access.BluetoothState.STATE_ON || state === access.BluetoothState.STATE_TURNING_ON) {
      return true;
    }
    return false;
  }

  enableBluetooth() {
    try {
      this.onBTStateChange();
      access.enableBluetooth();
    } catch (err) {
      LogUtil.error(TAG, `enableBluetooth: err = ${JSON.stringify(err)}`);
    }
  }

  disableBluetooth() {
    try {
      this.offBTStateChange();
      access.disableBluetooth();
    } catch (err) {
      LogUtil.error(TAG, `disableBluetooth: err = ${JSON.stringify(err)}`);
    }
  }

  buildService(): ble.GattService {

    let descriptors: Array<ble.BLEDescriptor> = [];
    const arrayBuffer = ArrayBufferUtils.byteArray2ArrayBuffer([11]);
    const descriptor: ble.BLEDescriptor = {
      serviceUuid: this.serviceUuid,
      characteristicUuid: this.wifiCharacteristicUuid,
      descriptorUuid: this.descriptorUuid,
      descriptorValue: arrayBuffer,
    };
    descriptors[0] = descriptor;

    let characteristics: Array<ble.BLECharacteristic> = [];
    let bufferCCC = new ArrayBuffer(8);
    let cccV = new Uint8Array(bufferCCC);
    cccV[0] = 1;
    cccV[1] = 2;
    let characteristic: ble.BLECharacteristic = {
      serviceUuid: this.serviceUuid,
      characteristicUuid: this.wifiCharacteristicUuid,
      characteristicValue: bufferCCC,
      descriptors: descriptors,
    };
    characteristics.push(characteristic);

    let characteristic2: ble.BLECharacteristic = {
      serviceUuid: this.serviceUuid,
      characteristicUuid: this.deviceUuidCharacteristicUuid,
      characteristicValue: this.stringToArrayBuffer(this.deviceUuid),
      descriptors: descriptors,
    };
    characteristics.push(characteristic2);

    const service: ble.GattService = {
      serviceUuid: this.serviceUuid,
      isPrimary: true,
      characteristics: characteristics,
      includeServices: [],
    };
    return service;
  }

  stringToArrayBuffer(str: string): ArrayBuffer {
    let encoder = new util.TextEncoder();
    const uint8Array = encoder.encodeInto(str);
    return uint8Array.buffer;
  }

  addService() {
    try {
      this.mGattServer.addService(this.service);

    } catch (err) {
      LogUtil.error(TAG, `addService: err = ${JSON.stringify(err)}`);
    }
  }

  registerCallback() {
    try {
      this.mGattServer.on('connectionStateChange', this.connectionStateChangeFunc);
      this.mGattServer.on('characteristicRead', this.ReadCharacteristicReq);
      this.mGattServer.on('characteristicWrite', this.WriteCharacteristicReq);
    } catch (err) {
      LogUtil.error(TAG, `connectInner: err = ${JSON.stringify(err)}`);
    }

  }

  startAdvertiser(): boolean {
    if (!this.isBluetoothEnabled()) {
      this.enableBluetooth();
      return false;
    }
    try {
      let setting: ble.AdvertiseSetting = {
        interval: 160,
        txPower: 1,
        connectable: true,
      };
      let advData: ble.AdvertiseData = {
        serviceUuids: [this.service.serviceUuid],
        manufactureData: [],
        serviceData: [],
        includeDeviceName: true,
      };
      let advResponse: ble.AdvertiseData = {
        serviceUuids: [this.service.serviceUuid],
        manufactureData: [],
        serviceData: [],
      };
      this.bleState = '广播中';
      ble.startAdvertising(setting, advData, advResponse);
      return true;
    } catch (err) {
      LogUtil.error(TAG, `startAdvertiser: err = ${JSON.stringify(err)}`);
    }
    return false;
  }

  ReadCharacteristicReq = (characteristicReadRequest: ble.CharacteristicReadRequest) => {
    if (characteristicReadRequest.serviceUuid === this.serviceUuid &&
      characteristicReadRequest.characteristicUuid === this.deviceUuidCharacteristicUuid) {
      this.ReadDeviceUuidCharacteristicReq(characteristicReadRequest);
    }
  }

  ReadDeviceUuidCharacteristicReq(characteristicReadRequest: ble.CharacteristicReadRequest) {
    let arrayBufferCCC = this.stringToArrayBuffer(this.deviceUuid);
    let deviceId: string = characteristicReadRequest.deviceId;
    let transId: number = characteristicReadRequest.transId;
    let offset: number = characteristicReadRequest.offset;
    let serverResponse: ble.ServerResponse = {
      deviceId: deviceId,
      transId: transId,
      status: 0,
      offset: offset,
      value: arrayBufferCCC,
    };

    try {
      this.mGattServer?.sendResponse(serverResponse);
    } catch (err) {
      console.error('errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  stopAdvertiser() {
    if (!this.mGattServer) {
      return;
    }
    try {
      ble.stopAdvertising();
      this.bleState = '';
    } catch (err) {
      LogUtil.error(TAG, `stopAdvertiser: err = ${JSON.stringify(err)}`);
    }
  }

  private stateChangeFunc = (data: access.BluetoothState): void => {
    if (data === access.BluetoothState.STATE_ON) {
      AppStorage.setOrCreate('bluetoothEnable', true);
    } else if (data === access.BluetoothState.STATE_OFF) {
      AppStorage.setOrCreate('bluetoothEnable', false);
    }
  };
  private connectionStateChangeFunc = (data: ble.BLEConnectionChangeState): void => {
    if (data) {
      if (data.state === constant.ProfileConnectionState.STATE_CONNECTED) {
        this.bleState = '已连接';
      } else if (data.state === constant.ProfileConnectionState.STATE_DISCONNECTED) {
        this.bleState = '已断开';
      }
    }
  };

  private onBTStateChange() {
    try {
      access.on('stateChange', this.stateChangeFunc);
    } catch (err) {
      LogUtil.error(TAG, `onBTSateChange: err = ${JSON.stringify(err)}`);
    }
  }

  private offBTStateChange() {
    try {
      access.off('stateChange');
    } catch (err) {
      LogUtil.error(TAG, `offBTSateChange: err = ${JSON.stringify(err)}`);
    }
  }
}
