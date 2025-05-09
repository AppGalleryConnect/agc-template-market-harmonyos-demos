import { BusinessError } from '@kit.BasicServicesKit';
import { bufferToString } from './BufferUtil';

export function getDataFromJSON<T>(rawFileName: string, component?: Object): T[] {
  let result: T[] = [];
  try {
    let value: Uint8Array = getContext(component).resourceManager.getRawFileContentSync(rawFileName);
    result = JSON.parse(bufferToString(value.buffer)) as T[];
  } catch (error) {
    let code = (error as BusinessError).code;
    let message = (error as BusinessError).message;
    console.error(`getRawFileContentSync failed, error code: ${code}, message: ${message}.`);
  }

  return result;
}