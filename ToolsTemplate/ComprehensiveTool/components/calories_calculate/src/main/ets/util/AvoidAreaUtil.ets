import { AppStorageV2 } from '@kit.ArkUI';

export class AreaType {
  top: number = 0;
  bottom: number = 0;
}

@ObservedV2
export class AvoidAreaUtil {
  private static avoidArea: AreaType = AppStorageV2.connect(AreaType, 'avoidArea', () => new AreaType())!;

  public static getTopHeight() {
    return AvoidAreaUtil.avoidArea.top;
  }

  public static getBottomHeight() {
    return AvoidAreaUtil.avoidArea.bottom;
  }

  public static setAvoidArea(top: number, bottom: number) {
    AvoidAreaUtil.avoidArea.top = top;
    AvoidAreaUtil.avoidArea.bottom = bottom;
  }
}