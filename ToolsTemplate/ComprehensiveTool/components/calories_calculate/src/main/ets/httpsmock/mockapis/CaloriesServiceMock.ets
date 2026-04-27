import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { CustomFoodBody, DietPlanBody } from '../../model/Calories';
import {
  addCustomFood,
  addDietPlans,
  getFoodCategory,
  queryDietPlan,
  queryDietPlans,
  searchFoodByName,
} from '../Calories';

export class ExchangeServiceMock {
  public start(adapter: AxiosMockAdapter) {
    adapter.onGet('/calories/food-category').reply(() => {
      let list = getFoodCategory();
      return [HttpStatusCode.Ok, list];
    });

    adapter.onPost('/calories/add-diet-plans').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as DietPlanBody;
      addDietPlans(data);
      return [HttpStatusCode.Ok];
    });

    adapter.onGet('/calories/diet-plans').reply(() => {
      return [HttpStatusCode.Ok, queryDietPlans()];
    });

    adapter.onGet('/calories/diet-plan').reply((config: AxiosRequestConfig) => {
      const menuId: number = config.params.menuId
      return [HttpStatusCode.Ok, queryDietPlan(menuId)];
    });

    adapter.onGet('/calories/search').reply((config: AxiosRequestConfig) => {
      const name: string = config.params.name;
      return [HttpStatusCode.Ok, searchFoodByName(name)];
    });

    adapter.onPost('/calories/food').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as CustomFoodBody;
      addCustomFood(data);
      return [HttpStatusCode.Ok];
    });
  }
}