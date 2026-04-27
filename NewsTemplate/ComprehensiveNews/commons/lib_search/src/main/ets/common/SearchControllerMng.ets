import { SearchViewController } from 'module_search';

/**
 * 搜索控制器管理类
 */
export class SearchControllerMng {
  private static controllerMap: Map<string, SearchViewController> = new Map();

  public static addController(name: string, controller: SearchViewController) {
    SearchControllerMng.controllerMap.set(name, controller);
  }

  public static deleteController(name: string) {
    SearchControllerMng.controllerMap.delete(name);
  }

  public static closeAllPop() {
    SearchControllerMng.controllerMap.forEach((controller: SearchViewController) => {
      controller.closePop();
    })
  }

  public static destroy() {
    SearchControllerMng.controllerMap.clear();
  }
}