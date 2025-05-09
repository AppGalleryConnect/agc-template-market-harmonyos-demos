import { ARGB } from '@common/customtypes';

export class CategoryUtils {

  public static argbToHexColor(argb: ARGB): string {
    let color: string = '#'
    for (let v of argb) {
      color = color + v.toString(16).toUpperCase().padStart(2, '0');
    }
    return color;
  }
}
