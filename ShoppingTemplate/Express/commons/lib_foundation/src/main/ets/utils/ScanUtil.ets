import { scanBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { Logger } from './Logger';
import { ContextUtil } from './ContextUtil';

export class ScanUtil {
  public static scan(obj: Object): void {
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL, scanCore.ScanType.ONE_D_CODE], enableMultiMode: true, enableAlbum: true,
    };
    try {
      scanBarcode.startScanForResult(ContextUtil.globalContext as common.UIAbilityContext, options)
        .then((result: scanBarcode.ScanResult) => {
          Logger.info('[BikeTravel]', 'Promise scan result:' + JSON.stringify(result));
        })
        .catch((error: BusinessError) => {
          Logger.error('[BikeTravel]', 'Promise error: %{public}s', JSON.stringify(error));
        });
    } catch (error) {
      Logger.error('[BikeTravel]', 'failReason: %{public}s', JSON.stringify(error));
    }
  }

  public static async getScanResult(obj: Object): Promise<string> {
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL, scanCore.ScanType.ONE_D_CODE], enableMultiMode: true, enableAlbum: true,
    };

    try {
      let result: scanBarcode.ScanResult =
        await scanBarcode.startScanForResult(ContextUtil.globalContext as common.UIAbilityContext, options);
      return result.originalValue;
    } catch (e) {
      Logger.error(JSON.stringify(e))
      return new Promise((resolve) => {
        resolve('')
      })
    }
  }
}