import { scanBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Logger';

export class ScanUtil {
  public static scan(context: Context): void {
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL, scanCore.ScanType.ONE_D_CODE], enableMultiMode: true, enableAlbum: true
    };
    try {
      scanBarcode.startScanForResult(context, options).then((result: scanBarcode.ScanResult) => {
        Logger.info('[BikeTravel]', 'Promise scan result:' + JSON.stringify(result));
      }).catch((error: BusinessError) => {
        Logger.error('[BikeTravel]', 'Promise error: %{public}s', JSON.stringify(error));
      });
    } catch (error) {
      Logger.error('[BikeTravel]', 'failReason: %{public}s', JSON.stringify(error));
    }
  }

  public static async getScanResult(context:Context): Promise<string> {
    try {
      let options: scanBarcode.ScanOptions = {
        scanTypes: [scanCore.ScanType.ALL, scanCore.ScanType.ONE_D_CODE], enableMultiMode: true, enableAlbum: true
      };

      let result: scanBarcode.ScanResult = await scanBarcode.startScanForResult(context, options);
      return result.originalValue;
    } catch (e) {
      return ''
    }
  }
}