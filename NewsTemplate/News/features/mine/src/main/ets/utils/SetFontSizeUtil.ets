const TAG: string = '[SetFontSizeUtil]';

export class SetFontSizeUtil {
  public static getTextByFontSize(fontSize: number): string  {
    let fontSizeText: string = '';
    switch (fontSize) {
      case 12:
        fontSizeText = '小';
        break;
      case 14:
        fontSizeText = '标准';
        break;
      case 16:
        fontSizeText = '大';
        break;
      case 18:
        fontSizeText = '特大';
        break;
      case 20:
        fontSizeText = '超大';
        break;
      default:
        fontSizeText = '标准';
    }
    return fontSizeText;
  }
}