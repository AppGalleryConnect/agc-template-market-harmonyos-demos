import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import Logger from '../common/Constant'

export class SystemUtil {
  static context: common.UIAbilityContext | null = null

  static startBrowsableAbility(uri: string): Promise<void> {
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: uri,
    };
    return new Promise((resolve, reject) => {
      SystemUtil.context?.startAbility(want)
        .catch((err: object) => {
          Logger.error(`startBrowsableAbility failed：${JSON.stringify(err)}`)
          reject(err);
        });
    })
  }

  static startEmailAbility(recipient: string, subject: string, body: string): Promise<void> {
    return new Promise((resolve, reject) => {
      const mailtoUri = `mailto:${recipient}?subject=${subject}&body=${body}`;
      SystemUtil.context?.startAbility({ uri: mailtoUri })
        .catch((err: BusinessError) => {
          Logger.error(`startEmailAbility failed：${JSON.stringify(err)}`);
          reject(err)
        });
    })
  }

  // 启动扫码
  static startScanAbility(context: common.Context | undefined): Promise<string> {
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: false,
      enableAlbum: true,
    };
    return new Promise((resolve, reject) => {
      scanBarcode.startScanForResult(context, options)
        .then((result: scanBarcode.ScanResult) => {
          resolve(result.originalValue)
        })
        .catch((err: BusinessError) => {
          Logger.error(`startScanAbility failed：${JSON.stringify(err)}`);
          reject(err);
        });
    })

  }
}