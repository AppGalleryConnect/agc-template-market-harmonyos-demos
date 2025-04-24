import { AdapterModel } from 'external_interactions';
import { BleClientModel } from '../model/BleClientModel';
import { GetWifiInfoModel } from '../model/GetWifiInfoModel';

export class SelectWifiViewModel {
  deviceId: string
  deviceName: string = ''
  deviceImage: ResourceStr = ''
  allWifi: string[] = []

  bleClientModel = BleClientModel.getInstance()

  constructor(deviceId: string) {
    this.deviceId = deviceId

    let deviceInfo = this.bleClientModel.getBleDeviceInfo(deviceId)
    if (deviceInfo === undefined) {
      return
    }
    this.deviceName = deviceInfo.deviceName
    this.deviceImage = AdapterModel.getInstance().getDeviceInfo(this.deviceName).deviceInfo.deviceImage
    this.GetWifi()
  }

  GetWifi(): void {
    let scanInfoList = GetWifiInfoModel.getInstance().getScanInfo();
    scanInfoList.forEach((item) => {
      if (item.ssid) {
        this.allWifi.push(item.ssid);
      }
    })
  }

  setWifi(wifiName: string, wifiPassword: string) {
    this.bleClientModel.setWifi(this.deviceId, wifiName, wifiPassword)
  }
}