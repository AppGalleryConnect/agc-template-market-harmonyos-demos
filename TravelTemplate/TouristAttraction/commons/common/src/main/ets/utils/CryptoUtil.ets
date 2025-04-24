import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';

export function doRandBySync(len: number): string {
  let data: string = '';
  let rand = cryptoFramework.createRandom();
  try {
    let randData = rand.generateRandomSync(len);
    if (randData != null) {
      for (let i = 0; i < randData.data.length; i++) {
        data += randData.data[i];
      }
    } else {
      Logger.error('[Sync]: get rand result fail!');
    }
  } catch (error) {
    let e: BusinessError = error as BusinessError;
    Logger.error(`do rand failed, ${e.code}, ${e.message}`);
  }
  return data;
}