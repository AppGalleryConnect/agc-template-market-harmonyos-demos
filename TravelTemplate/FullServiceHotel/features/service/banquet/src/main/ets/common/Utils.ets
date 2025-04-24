import { MeasureText } from '@kit.ArkUI';

const REGEX: RegExp = /^-?(0(\.\d+)?|[1-9]\d*(\.\d+)?)$/;

export default class Utils {
  public static parseNumber(value: string): number {
    if (!REGEX.test(value)) {
      return Number.NaN;
    }
    return parseFloat(value);
  }

  public static validateNumbers(...values: number[]): boolean {
    for (let value of values) {
      if (isNaN(value)) {
        return false;
      }
    }
    return true;
  }

  public static calcTextWidth(text: string, fontSizeVP: number): number {
    try {
      let fontSizePX: number = 0;
      let textSize: SizeOptions = MeasureText.measureTextSize({ textContent: text, fontSize: fontSizeVP });
      if (textSize.width !== undefined) {
        fontSizePX = Math.ceil(parseFloat(textSize.width.toString()));
      }
      return px2vp(fontSizePX);
    } catch (e) {
      return NaN;
    }
  }

  public static toRadians(angleInDegrees: number): number {
    return angleInDegrees * Math.PI / 180;
  }

  public static toDegrees(angleInRadians: number): number {
    return angleInRadians * 180 / Math.PI;
  }
}
