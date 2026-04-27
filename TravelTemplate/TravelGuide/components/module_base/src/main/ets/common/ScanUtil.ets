import { scanBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Logger';

export class ScanUtil {
  public static scan(obj: Object): void {
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL, scanCore.ScanType.ONE_D_CODE], enableMultiMode: true, enableAlbum: true
    };
    try {
      scanBarcode.startScanForResult(getContext(obj), options).then((result: scanBarcode.ScanResult) => {
        Logger.info('[BikeTravel]', 'Promise scan result:' + JSON.stringify(result));
      }).catch((error: BusinessError) => {
        Logger.error('[BikeTravel]', 'Promise error: %{public}s', JSON.stringify(error));
      });
    } catch (error) {
      Logger.error('[BikeTravel]', 'failReason: %{public}s', JSON.stringify(error));
    }
  }

  public static async getScanResult(obj: Object): Promise<string> {
    let result: scanBarcode.ScanResult = Object()
    try {
      let options: scanBarcode.ScanOptions = {
        scanTypes: [scanCore.ScanType.ALL, scanCore.ScanType.ONE_D_CODE], enableMultiMode: true, enableAlbum: true
      };
      result = await scanBarcode.startScanForResult(getContext(obj), options);
    } catch (err) {
    }
    return result.originalValue;
  }
}