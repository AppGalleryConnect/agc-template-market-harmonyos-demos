export class NavParams {
  static navPathStack?: any

  public static setNavPathStack(navPathStack: any): void {
    NavParams.navPathStack = navPathStack;
  }

  public static getParams(): any {
    if (NavParams.navPathStack?.getAllPathName().length) {
      return NavParams.navPathStack?.getParamByIndex(NavParams.navPathStack?.getAllPathName().length - 1) as object;
    }
    return undefined;
  }
}