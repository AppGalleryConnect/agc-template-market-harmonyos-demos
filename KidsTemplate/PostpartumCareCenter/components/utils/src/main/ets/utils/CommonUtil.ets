export class CommonUtil {
  public static isStringValid(input: string | null | undefined): boolean {
    return input !== null && input !== undefined && input.length > 0;
  }
}