import { AppStorageV2 } from '@kit.ArkUI';

export class AreaType {
  top: number = 0;
  bottom: number = 0;
}

@ObservedV2
export class ZipAvoidAreaUtil {
  private static avoidArea: AreaType = AppStorageV2.connect(AreaType, 'avoidArea', () => new AreaType())!;

  public static getZipTopHeight() {
    return ZipAvoidAreaUtil.avoidArea.top;
  }
}