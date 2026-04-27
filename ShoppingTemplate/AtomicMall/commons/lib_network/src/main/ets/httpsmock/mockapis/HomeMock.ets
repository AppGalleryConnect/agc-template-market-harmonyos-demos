import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { RequestUrlMap } from '../../constants/RequestUrlMap';
import {
  CategoryItem, CategoryProductListResp, HomeConfigResp,
  ProductSummaryItem,
} from '../../types/responses/HomeConfigResponse';
import { MockHomeConfig } from '../mockdata/MockHomeData';
import { MockImageData } from '../mockdata/MockImageMap';

export class HomeMockApis {
  public start(adapter: AxiosMockAdapter) {
    // 获取首页配置信息
    adapter.onGet(RequestUrlMap.COMMON_HOME_CONFIG).reply(() => {
      const categoryBarList = MockHomeConfig.categoryBarList.map((category) => ({
        id: category.id,
        label: category.label,
        iconUrl: MockImageData.getImageResource(category.iconUrl),
        subCategory: category.subCategory,
      } as CategoryItem));
      const res: HomeConfigResp = {
        code: 0,
        categoryList: categoryBarList,
        searchList: MockHomeConfig.searchList,
        bannerList: MockHomeConfig.bannerList.map((item) => MockImageData.getImageResource(item) ),
      };
      return [HttpStatusCode.Ok, res];
    });

    // 获取分类内商品
    adapter
      .onGet(RequestUrlMap.COMMON_CATEGORY_PRODUCT)
      .reply((config: AxiosRequestConfig) => {
        const subId = config.params.subId as string;
        let list = MockHomeConfig.categoryDataList.map((data)=>({
          banner: MockImageData.getImageResource(data.banner),
          title:data.title,
          id: data.id,
          subCategoryId: data.subCategoryId,
        } as ProductSummaryItem));
        if (subId) {
          list = list.filter((product) => product.subCategoryId === subId);
        }
        const res: CategoryProductListResp = {
          code: 0,
          productList: list,
        };
        return [HttpStatusCode.Ok, res];
      });
  }
}
