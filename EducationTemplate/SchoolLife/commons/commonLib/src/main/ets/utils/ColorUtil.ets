

class ColorUtil {
  public getResourceColor(resourceColorName: string, opacity: number = 1): string {
    const opacityStr = Math.max(0, Math.min(Math.round(opacity * 255), 255)).toString(16).padStart(2, '0').toLowerCase();
    const colorValue = getContext(this).resourceManager.getColorByNameSync(resourceColorName).toString(16);
    return '#' + opacityStr + colorValue.substring(2);
  }
}

const colorUtil = new ColorUtil();
export { colorUtil as ColorUtil };