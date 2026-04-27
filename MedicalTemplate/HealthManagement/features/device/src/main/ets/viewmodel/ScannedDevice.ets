import { connection } from '@kit.ConnectivityKit';
import { Type } from '@kit.ArkUI';
import { systemDateTime } from '@kit.BasicServicesKit';
import { DeviceModel } from './DeviceModel';

@ObservedV2
export class PairedDeviceModel {
  @Trace deviceId: string = '';
  @Trace keyId: string = '';
  @Trace deviceName: string = '';
  @Trace battery: number = 90;
  @Trace chargeCycles: number = 10;
  @Trace pairState: connection.BondState = connection.BondState.BOND_STATE_INVALID;
}

@ObservedV2
export class PairedDeviceMacList {
  // 关键修复：为数组添加@Type声明元素类型
  @Type(PairedDeviceModel)
  @Trace pairedList: PairedDeviceModel[] = [];
}

/**
 * 扫描设备VM类
 */
@ObservedV2
export class ScannedDevice {
  @Trace deviceId: string;
  @Trace keyId: string = '';
  @Trace deviceName: string = '';
  @Trace pairState: connection.BondState = connection.BondState.BOND_STATE_INVALID;

  constructor(deviceId: string, name?: string) {
    this.deviceId = deviceId;
    this.keyId = systemDateTime.getTime(true).toString();
    if (DeviceModel.instance.isBluetoothEnabled()) {
      try {
        this.pairState = connection.getPairState(deviceId);
        if (name === undefined || name.length === 0) {
          this.deviceName = connection.getRemoteDeviceName(deviceId);
        } else {
          this.deviceName = name;
        }
      } catch (err) {
      }
    }
  }
}