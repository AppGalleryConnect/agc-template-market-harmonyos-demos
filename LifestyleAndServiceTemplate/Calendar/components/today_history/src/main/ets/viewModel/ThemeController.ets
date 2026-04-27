@ObservedV2
export class ThemeVM {
  @Trace selectColor:ResourceStr = '#c4272b'
  @Trace titleColor:ResourceStr = '#ffffff'
  private static _instance: ThemeVM
  static get instance() {
    if (!ThemeVM._instance) {
      ThemeVM._instance = new ThemeVM()
    }
    return ThemeVM._instance
  }

  setTheme(selectColor:ResourceStr,titleColor:ResourceStr) {
    this.selectColor = selectColor
    this.titleColor = titleColor
  }
}