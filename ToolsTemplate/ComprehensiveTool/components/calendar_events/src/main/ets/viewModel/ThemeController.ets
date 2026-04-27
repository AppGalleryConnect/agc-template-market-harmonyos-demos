@ObservedV2
export class ThemeVM {
  private static _instance: ThemeVM
  @Trace titleColor:ResourceStr = '#c4272b'
  @Trace selectColor:ResourceStr = '#c4272b'

  setTheme(selectColor:ResourceStr,titleColor:ResourceStr) {
    this.selectColor = selectColor
    this.titleColor = titleColor
  }

  static get instance() {
    if (!ThemeVM._instance) {
      ThemeVM._instance = new ThemeVM()
    }
    return ThemeVM._instance
  }

}