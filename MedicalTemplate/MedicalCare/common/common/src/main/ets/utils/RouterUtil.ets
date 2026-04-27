import { LogUtil } from './LogUtil';

export class RouterUtil {
  public static navPathStack: NavPathStack = new NavPathStack();

  private constructor() {
  }

  static pushPathByName(name: string, param: object | null = null, onPop?: Callback<PopInfo>, animated?: boolean) {
    LogUtil.info(`RouterUtil route: ${name}`)
    RouterUtil.navPathStack.pushPathByName(name, param, onPop, animated)
  }

  static back(result?: object) {
    RouterUtil.navPathStack.pop(result)
  }

  static backTo(name: string) {
    RouterUtil.navPathStack.popToName(name)
  }

  static getLatestParam(): object {
    return RouterUtil.navPathStack.getParamByIndex(RouterUtil.navPathStack.getAllPathName().length - 1) as object
  }

  static getParam(name: string): object {
    return RouterUtil.navPathStack.getParamByName(name)[0] as object
  }
}