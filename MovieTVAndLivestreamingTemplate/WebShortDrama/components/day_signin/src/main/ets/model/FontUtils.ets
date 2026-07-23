import { display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';


export function fp2pxUtil(fp: number): string {
  const pxStr: string = 'px';
  let pxVal: number = 0;
  let displayClass: display.Display | null = null;
  try {
    displayClass = display.getDefaultDisplaySync();
    pxVal = fp * (displayClass.densityDPI / 160);
  } catch (err) {
    let error = err as BusinessError;
  }
  return pxVal + pxStr;
}