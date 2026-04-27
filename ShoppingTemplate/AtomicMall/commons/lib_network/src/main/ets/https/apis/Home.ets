import { RequestUrlMap } from '../../constants/RequestUrlMap';
import {
  CategoryProductListResp,
  HomeConfigResp,
} from '../../types/responses/HomeConfigResponse';
import request from '../Request';

class HomeApis {
  /**
   * 获取首页配置信息
   */
  public getHomeConfig(): Promise<HomeConfigResp> {
    return request.get(RequestUrlMap.COMMON_HOME_CONFIG);
  }

  /**
   * 获取分类内商品
   */
  public getCategoryProductList(
    subId: string,
  ): Promise<CategoryProductListResp> {
    return request.get(RequestUrlMap.COMMON_CATEGORY_PRODUCT, {
      params: { subId },
    });
  }
}

const instance = new HomeApis();

export { instance as HomeApis };
