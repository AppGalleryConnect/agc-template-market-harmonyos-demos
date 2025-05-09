import { RouterModule } from './commonRouter'

@ObservedV2
export class RouteEntryVM {
  private static _instance: RouteEntryVM;

  public static get instance() {
    if (!RouteEntryVM._instance) {
      RouteEntryVM._instance = new RouteEntryVM();
    }
    return RouteEntryVM._instance;
  }

  public init() {
    // 初始化数据
  }

  public toRouteDetail(url: string) {
    RouterModule.push({ url: url })
  }

  public toRouteReplace(url: string) {
    RouterModule.replace({ url: url })
  }

  public pushByParams<T>(url: string, param: T) {
    RouterModule.push({
      url: url,
      param: param
    })
  }

  public toPageDetail(url: string) {
    RouterModule.push({
      url: url
    })
  }

  // 跳转到搜索结果页
  public toSearchDetail(param?: Array<string>, pop?: Callback<PopInfo>) {
    RouterModule.push({
      url: 'SpecificContentSearch',
      param: param,
      onPop: pop
    })
  }

  public pop() {
    RouterModule.pop()
  }

  public clear() {
    RouterModule.clear('a');
  }

  public popValue(result: Object) {
    RouterModule.pop(result)
  }

  public popTop(url: string) {
    RouterModule.popToName(url)
  }

  public toRealTimeBus() {
    RouterModule.push({
      url: 'RealTimeBus'
    })
  }
}