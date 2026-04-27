import { display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from 'module_ui_base';

/**
 * fp2px
 * @param fp
 * @returns
 */
export function fp2pxUtil(fp: number): string {
  const pxStr: string = 'px';
  let pxVal: number = 0;
  let displayClass: display.Display | null = null;
  try {
    displayClass = display.getDefaultDisplaySync();
    pxVal = fp * (displayClass.densityDPI / 160);
  } catch (err) {
    let error = err as BusinessError;
    Logger.error(
      'fp2pxUtil',
      `get densityDPI failed. code: ${error.code}, message:${err.message}`,
    );
  }
  return pxVal + pxStr;
}
