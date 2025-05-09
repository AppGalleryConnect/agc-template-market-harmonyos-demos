import { i18n, intl } from '@kit.LocalizationKit'

export class CommonUtil {
  private static isRTL: boolean = i18n.isRTL((new intl.Locale()).language)

  public static setIsRTL(isRTL: boolean): void {
    CommonUtil.isRTL = isRTL
  }

  public static getIsRTL(): boolean {
    return CommonUtil.isRTL
  }
}