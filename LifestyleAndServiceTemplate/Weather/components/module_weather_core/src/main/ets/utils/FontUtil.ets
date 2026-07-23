import { PersistenceV2 } from '@kit.ArkUI';

@ObservedV2
class FontModel {
  /**
   * 1 or 1.5
   */
  @Trace rate: number = 1;
}

@ObservedV2
export class FontUtil {
  // 字体大小倍率
  private static _fontInfo: FontModel = new FontModel();

  public static setFontInfo() {
    FontUtil._fontInfo = PersistenceV2.connect(FontModel, 'fontInfo', () => new FontModel())!;
  }

  public static getRate() {
    return FontUtil._fontInfo.rate;
  }

  /**
   * 修改字体倍率
   * @param index 0-标准 1-大字
   */
  public static setRate(index: number) {
    if (index === 0) {
      FontUtil._fontInfo.rate = 1;
    } else if (index === 1) {
      FontUtil._fontInfo.rate = 1.15;
    }
  }
}

