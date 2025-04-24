import { AppStorageV2 } from '@kit.ArkUI';

export class StorageUtil {
  public static exists(key: string): boolean {
    const keys = AppStorageV2.keys()
    return keys.indexOf(key) >= 0
  }
}