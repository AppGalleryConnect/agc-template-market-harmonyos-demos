import { RouterModule } from './commonRouter';

@ObservedV2
export class RouteDetailVM {
  private static _instance: RouteDetailVM;

  public static get instance() {
    if (!RouteDetailVM._instance) {
      RouteDetailVM._instance = new RouteDetailVM();
    }
    return RouteDetailVM._instance;
  }

  public init() {
    // 初始化数据
    this.getRouterParams()
  }

  public getRouterParams() {
    let params: Array<ESObject> | undefined = RouterModule.getNavParam({
      url: ''
    })
    console.log('test', JSON.stringify(params))
  }
}

