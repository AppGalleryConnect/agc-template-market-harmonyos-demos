@ObservedV2
export class BreakPointUtils {
  private static breakPointEnum: Record<string, number> = {
    'sm': 16,
    'md': 24,
    'lg': 32,
    'xl': 32,
  }

  public static getBreakPointGutter(breakpoint: string) {
    return BreakPointUtils.breakPointEnum[breakpoint]
  }
}