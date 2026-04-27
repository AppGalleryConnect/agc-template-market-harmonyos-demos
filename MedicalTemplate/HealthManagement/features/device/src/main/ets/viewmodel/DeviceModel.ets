import { BusinessError, Callback, emitter, systemDateTime } from '@kit.BasicServicesKit';
import { common, Want } from '@kit.AbilityKit';
import { access, ble, connection } from '@kit.ConnectivityKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { Constants, PermissionUtil, RouterMap, TCLogger } from 'common';
import { PairedDeviceMacList, PairedDeviceModel, ScannedDevice } from './ScannedDevice';
import { HMConnectDialog } from '../comp/HMConnectDialog';
import { phoneRouterControl } from 'oh_router';
import { ScanningDevicePageBuilder } from '../views/ScanningDevicePage';
import { deviceScanDelay } from '../constants/Constants';

const TAG = 'DeviceModel';

export enum BLE_SCAN_STATE {
  INIT,
  SCANNING,
  SCANNED_SUCCESS,
  SCANNED_FAIL,
}

/**
 * 设备VM类
 */
@ObservedV2
export class DeviceModel {
  @Trace titleName: string = '设备名称';
  connectStatus: string = '添加设备';
  connectTip: string = '请开启设备的蓝牙';
  icon: ResourceStr = $r('app.media.device_add_btn');
  currentMainPage: boolean = true;
  @Trace macList: PairedDeviceMacList = PersistenceV2.connect(PairedDeviceMacList, () => new PairedDeviceMacList())!;
  uiContext?: UIContext;
  @Trace pairedDevices: ScannedDevice[] = [];
  private scannedDevicesMng = new Map<string, ScannedDevice>();
  @Trace scannedDevices: ScannedDevice[] = [];
  public currentId: string = '';
  private static _instance: DeviceModel;
  private timerId: number = 0;
  private clickCount: number = 0;

  public static get instance() {
    if (!DeviceModel._instance) {
      DeviceModel._instance = new DeviceModel();
      DeviceModel._instance.requestBluetoothPermissionsFromUser((isGrantStatus: boolean) => {
        if (isGrantStatus) {
          connection.on('bondStateChange', DeviceModel._instance.onBondStateChangeEvent);
          DeviceModel._instance.getPairDeviceInfo();
        }
      });
    }
    return DeviceModel._instance;
  }

  public startScan() {
    this.requestBluetoothPermissionsFromUser((isGrantStatus: boolean) => {
      if (isGrantStatus) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.DEVICE_SCANNING_PAGE,
          builder: wrapBuilder(ScanningDevicePageBuilder)
        })
      } else {
        // 权限失败
        this.showBluetoothAlertDialog();
      }
    });
  }

  getPairDeviceInfo() {
    clearTimeout(this.timerId);
    this.clickCount++;
    if (this.clickCount >= 2) {
      this.clickCount = 0;
      return;
    } else {
      this.timerId = setTimeout(() => {
        this.clickCount = 0;
      }, deviceScanDelay + deviceScanDelay);
    }

    for (let index = 0; index < this.macList.pairedList.length; index++) {
      let temp = this.macList.pairedList[index];
      if (DeviceModel.instance.isBluetoothEnabled()) {
        temp.pairState = connection.getPairState(temp.deviceId);
      } else {
        temp.pairState = connection.BondState.BOND_STATE_INVALID;
      }

      temp.keyId = systemDateTime.getTime(true).toString();
    }
  }

  requestBluetoothPermissionsFromUser(callback: Callback<boolean>) {
    PermissionUtil.checkPermissions('ohos.permission.ACCESS_BLUETOOTH')
      .then((isGrantStatus: boolean) => {
        TCLogger.info(TAG, `checkPermissions isGrantStatus=${isGrantStatus}`);
        callback(isGrantStatus);
      })
      .catch((err: BusinessError) => {
        TCLogger.error(TAG, `checkPermissions err=${JSON.stringify(err)}`);
        callback(false);
      })
  }

  // 开启蓝牙
  public startBleScan(): void {
    if (!this.isBluetoothEnabled()) {
      this.enableBluetooth()
      return
    }
    this.startBleScanInner()
  }

  // 关闭扫码
  public stopBleScan(): void {
    try {
      ble.off('BLEDeviceFind', this.OnBleDeviceFind);
      ble.stopBLEScan();

      connection.off('bluetoothDeviceFind', this.onBluetoothDeviceReceiveEvent);
      if (connection.isBluetoothDiscovering()) {
        connection.stopBluetoothDiscovery();
      }
    } catch (err) {
      TCLogger.error(TAG, 'stop scan, err: ' + JSON.stringify(err));
    }
  }

  // 开始扫描
  public startBleScanInner() {
    try {
      this.scannedDevicesMng.clear();
      this.scannedDevices = [];
      ble.on('BLEDeviceFind', this.OnBleDeviceFind);

      let scanOptions: ble.ScanOptions = {
        interval: 0,
        dutyMode: ble.ScanDuty.SCAN_MODE_LOW_POWER,
        matchMode: ble.MatchMode.MATCH_MODE_AGGRESSIVE
      }
      ble.startBLEScan(null, scanOptions);

      connection.on('bluetoothDeviceFind', this.onBluetoothDeviceReceiveEvent);
      connection.startBluetoothDiscovery();
    } catch (err) {
      TCLogger.error(TAG, 'start scan, err: ' + JSON.stringify(err));
    }
  }

  // 蓝牙是否开启
  public isBluetoothEnabled(): boolean {
    const state: access.BluetoothState = access.getState();
    return state === access.BluetoothState.STATE_ON ||
      state === access.BluetoothState.STATE_TURNING_ON;
  }

  // 开启蓝牙
  public enableBluetooth() {
    try {
      access.on('stateChange', this.OnBluetoothStateChange);
      access.enableBluetooth();
    } catch (err) {
      TCLogger.info(TAG, 'enable bluetooth err: ' + JSON.stringify(err));
    }
  }

  private OnBluetoothStateChange(data: access.BluetoothState) {
    try {
      TCLogger.info(TAG, 'OnBluetoothStateChange data: ' + data);
      if (data === access.BluetoothState.STATE_ON) {
        emitter.emit(Constants.onEnableBluetoothChange);
      } else if (data === access.BluetoothState.STATE_OFF) {
        this.scannedDevicesMng.clear()
        this.scannedDevices = [];
      }
    } catch (err) {
    }
  }

  // ble扫描结果
  private OnBleDeviceFind = (arr: Array<ble.ScanResult>) => {
    arr.forEach((item) => {
      let id: string = item.deviceId;
      let name: string = item.deviceName;
      if (this.scannedDevicesMng.has(id) || name === '') {
        return
      }

      for (let index = 0; index < this.macList.pairedList.length; index++) {
        let temp = this.macList.pairedList[index];
        if (temp.deviceId === id) {
          return;
        }
      }

      let scannedDevice = new ScannedDevice(id, name);
      this.scannedDevicesMng.set(id, scannedDevice);
      this.scannedDevices.push(scannedDevice);
    })
  }
  // 蓝牙扫描结果
  private onBluetoothDeviceReceiveEvent = (data: Array<string>) => {
    try {
      data.forEach((deviceId: string) => {
        let deviceName = connection.getRemoteDeviceName(deviceId);
        if (this.scannedDevicesMng.has(deviceId) || deviceName === '') {
          return
        }

        for (let index = 0; index < this.macList.pairedList.length; index++) {
          let temp = this.macList.pairedList[index];
          if (temp.deviceId === deviceId) {
            return;
          }
        }

        let scannedDevice = new ScannedDevice(deviceId);
        this.scannedDevicesMng.set(deviceId, scannedDevice);
        this.scannedDevices.push(scannedDevice);
      })
    } catch (err) {
    }
  }
  // 配对状态变化结果
  private onBondStateChangeEvent = (data: connection.BondStateParam) => {
    try {
      TCLogger.info(TAG, 'on bond state change event state= ' + JSON.stringify(data));
      if (this.currentId !== data.deviceId) {
        // 只有配对时才会弹框
        return;
      }

      let pairedDeviceVM = new PairedDeviceModel();
      pairedDeviceVM.deviceId = data.deviceId;
      this.initPairedDevice(pairedDeviceVM);

      if (data.state === 2) {
        let isContain = false;
        for (let index = 0; index < this.macList.pairedList.length; index++) {
          let temp = this.macList.pairedList[index];
          if (temp.deviceId === data.deviceId) {
            isContain = true;
            break;
          }
        }
        if (!isContain) {
          this.macList.pairedList.push(pairedDeviceVM)
        }
      }

      if (data.state === 2 || data.state === 0) {
        HMConnectDialog.ShowConnectPopup(pairedDeviceVM);
        this.currentId = '';
      }

      emitter.emit(Constants.onBluetoothScanningChange);
    } catch (err) {
    }
  }

  // 配对
  public pairDevice(deviceId: string) {
    if (!this.isBluetoothEnabled()) {
      this.enableBluetooth()
      return
    }

    try {
      this.currentId = deviceId;
      connection.pairDevice(deviceId, (err: BusinessError, data) => {
        if (err) {
          TCLogger.info(TAG, 'pairDevice, err: ' + JSON.stringify(err));
          HMConnectDialog.ShowConnectPopup(new PairedDeviceModel());
          this.currentId = '';
        } else {
          TCLogger.info(TAG, 'pairDevice, data: ' + JSON.stringify(data));
        }
      });
    } catch (err) {
      TCLogger.error(TAG, 'pairDevice, catch err: ' + JSON.stringify(err));
      HMConnectDialog.ShowConnectPopup(new PairedDeviceModel());
      this.currentId = '';
    }
  }

  initPairedDevice(deviceVM: PairedDeviceModel) {
    deviceVM.keyId = systemDateTime.getTime(true).toString();
    if (this.isBluetoothEnabled()) {
      try {
        deviceVM.pairState = connection.getPairState(deviceVM.deviceId);
        deviceVM.deviceName = connection.getRemoteDeviceName(deviceVM.deviceId);
      } catch (err) {
      }
    }
  }

  checkPairState(deviceId: string) {
    try {
      if (!DeviceModel.instance.isBluetoothEnabled()) {
        DeviceModel.instance.enableBluetooth()
        return
      }

      let pairState = connection.getPairState(deviceId);
      if (pairState === connection.BondState.BOND_STATE_INVALID) {
        for (let index = 0; index < this.macList.pairedList.length; index++) {
          let temp = this.macList.pairedList[index];
          if (temp.deviceId === deviceId) {
            this.macList.pairedList.splice(index, 1);
            break;
          }
        }

        emitter.emit(Constants.onPairDeviceChange);
        emitter.emit(Constants.onHealthDataChange);
        phoneRouterControl.popPage();
      }
    } catch (err) {
    }
  }

  showBluetoothAlertDialog() {
    this.uiContext?.showAlertDialog({
      title: $r('app.string.device_bluetooth_dialog_title'),
      message: $r('app.string.device_bluetooth_dialog_message'),
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: -20 },
      gridCount: 4,
      confirm: {
        value: $r('app.string.device_bluetooth_dialog_confirm'),
        action: () => {
          this.jumpToAppSettings();
          TCLogger.info(TAG, 'Button-clicking callback');
        }
      },
      cancel: () => {
        TCLogger.info(TAG, 'Closed callbacks');
      }
    })
  }

  openBluetoothAlertDialog() {
    this.uiContext?.showAlertDialog({
      title: '蓝牙开关',
      message: '系统蓝牙开关未打开，前往应用中心打开',
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: -20 },
      gridCount: 4,
      confirm: {
        value: $r('app.string.device_bluetooth_dialog_confirm'),
        action: () => {
          this.openAppInfo();
          TCLogger.info(TAG, 'Button-clicking callback');
        }
      },
      cancel: () => {
        TCLogger.info(TAG, 'Closed callbacks');
      }
    })
  }

  openAppInfo() {
    let context = this.uiContext?.getHostContext() as common.UIAbilityContext;
    let want: Want = {
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',
      uri: 'bluetooth_entry',
      parameters: {
        bundleName: context?.abilityInfo.bundleName,
        pushParams: context?.abilityInfo.bundleName,
      }
    };
    context?.startAbility(want);
  };

  jumpToAppSettings() {
    let context = this.uiContext?.getHostContext() as common.UIAbilityContext;
    let want: Want = {
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',
      uri: 'application_info_entry',
      parameters: {
        bundleName: context?.abilityInfo.bundleName,
        pushParams: context?.abilityInfo.bundleName,
      }
    };
    context?.startAbility(want);
  }
}