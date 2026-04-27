import { CustomFoodBody, DietPlanBody, DietPlans, FoodCalories,
  FoodCategory,
  FoodPlanCaloriesBody } from '../../model/Calories';
import request from '../Request';
// 启动mock
import('../../httpsmock/MockAdapter');

export class CaloriesService {
  /**
   * 查询饮食列表
   * @returns
   */
  queryFoodCategory(): Promise<Array<FoodCategory>> {
    const url = '/calories/food-category';
    return request.get(url);
  };

  /**
   * 查询饮食计划列表
   * @returns
   */
  queryDietPlans(): Promise<Array<DietPlans>> {
    const url = '/calories/diet-plans';
    return request.get(url);
  };

  /**
   * 根据id查询饮食计划
   * @returns
   */
  queryDietPlan(menuId: number): Promise<DietPlans> {
    const url = '/calories/diet-plan';
    return request.get(url, { params: { menuId } });
  };

  /**
   * 查询饮食计划
   * @returns
   */
  addDietPlans(menuId: number, name: string, foodList: FoodPlanCaloriesBody[]): Promise<number> {
      const url = '/calories/add-diet-plans';
      const data: DietPlanBody = {
        menuId,
        name,
        foodList,
      };
      return request.post(url, data);
    };

  /**
   * 搜索食物
   * @returns
   */
  searchFoodByName(name: string): Promise<Array<FoodCalories>> {
    const url = '/calories/search';
    return request.get(url, { params: { name } });
  };

  /**
   * 添加自定义食物
   * @returns
   */
  addCustomFood(data: CustomFoodBody): Promise<CustomFoodBody> {
    const url = '/calories/food';
    return request.post(url, data);
  };
}

const instance = new CaloriesService();

export { instance as CaloriesServiceApi };