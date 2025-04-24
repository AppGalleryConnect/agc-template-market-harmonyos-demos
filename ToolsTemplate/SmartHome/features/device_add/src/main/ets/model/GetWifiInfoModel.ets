import { wifiManager } from '@kit.ConnectivityKit';

export class GetWifiInfoModel {
  scanInfoList: Array<wifiManager.WifiScanInfo> = [];

  private static _instance: GetWifiInfoModel;

  private uniqueBySsid(arr: Array<wifiManager.WifiScanInfo>): Array<wifiManager.WifiScanInfo> {
    const set = new Set<string>();
    return arr.filter((item) => {
      const key = item.ssid;
      if (!set.has(key)) {
        set.add(key);
        return true;
      }
      return false;
    });
  }

  public getScanInfo(): Array<wifiManager.WifiScanInfo> {
    let temp = wifiManager.getScanInfoList();
    if (temp.length > 0) {
      this.scanInfoList = this.uniqueBySsid(temp);
    }
    return this.scanInfoList;
  }

  public static getInstance() {
    if (!GetWifiInfoModel._instance) {
      GetWifiInfoModel._instance = new GetWifiInfoModel();
    }
    return GetWifiInfoModel._instance;
  }
}