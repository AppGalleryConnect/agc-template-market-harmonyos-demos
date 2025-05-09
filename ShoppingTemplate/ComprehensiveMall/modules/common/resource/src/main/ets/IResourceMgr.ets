import util from '@ohos.util';
import { Config } from '@common/const';

export class IResourceMgr {

  public resolveUri(uri: string | undefined | null): ResourceStr {
    try {
      if (!uri) {
        return '';
      } else if (uri.startsWith('app://dev')) {
        return Config.IS_DEV ? $rawfile(uri.slice(6)) : '';
      } else if (uri.startsWith('app://prod')) {
        return $rawfile(uri.slice(6));
      } else if (!uri.startsWith('http://') && !uri.startsWith('https://')) {
        return Config.API_BASE_URL + uri;
      } else {
        return uri;
      }
    } catch (e) {
      return '';
    }
  }

  public readResourceAsString(path: string, encoding: string = 'utf-8'): string {
    try {
      const result: Uint8Array = getContext(this).resourceManager.getRawFileContentSync(path);
      const decode: util.TextDecoder = util.TextDecoder.create(encoding, {fatal: false, ignoreBOM: false});
      return decode.decodeToString(result, { stream: false });
    } catch (e) {
      return '';
    }
  }
}
