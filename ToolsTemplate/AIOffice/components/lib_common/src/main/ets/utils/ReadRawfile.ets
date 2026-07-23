import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { GlobalContext } from './GlobalContext';

function bufferToString(buffer: ArrayBufferLike): string {
  let textDecoder = util.TextDecoder.create('utf-8', {
    ignoreBOM: true
  });
  let resultPut = textDecoder.decodeToString(new Uint8Array(buffer), {
    stream: true
  });
  return resultPut;
}

export function getDataFromJSON<T>(rawFileName: string, component?: Object): T[] {
  let result: T[] = [];
  try {
    let value: Uint8Array = GlobalContext.getContext().resourceManager.getRawFileContentSync(rawFileName);
    result = JSON.parse(bufferToString(value.buffer)) as T[];
  } catch (error) {
    let code = (error as BusinessError).code;
    let message = (error as BusinessError).message;
    console.error(`getRawFileContentSync failed, error code: ${code}, message: ${message}.`);
  }

  return result;
}