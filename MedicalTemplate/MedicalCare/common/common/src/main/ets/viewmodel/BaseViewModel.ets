import { RouterUtil } from '../utils/RouterUtil';

/**
 * 所有ViewModel的基类，定义一些通用操作
 */
@ObservedV2
export abstract class BaseViewModel {
  @Trace isLoading: boolean = false

  public toPage(pageName: string, param?: object, onPop?: Callback<PopInfo>, animated?: boolean) {
    RouterUtil.pushPathByName(pageName, param, onPop, animated)
  }

  public getLoadingCallback(): (isLoading: boolean) => void {
    return (isLoading: boolean) => {
      this.isLoading = isLoading
    }
  }
}