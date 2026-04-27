import { CaloriesServiceApi } from '../https/apis/CaloriesService';
import { DietPlans, FoodPlanCalories } from '../model/Index';

@ObservedV2
export class CaloriesPageVM {
  @Trace tabNames: ResourceStr[] = ['日', '周']
  @Trace tabIndex: number = 1
  @Trace dietPlanList: DietPlans[] = []
  @Trace seriesData: number[] = [1500, 1250, 1200, 1280, 1650, 1700, 1600];
  gradientColor: LinearGradient =
    new LinearGradient([{ color: '#83CE26', offset: 0.25 }, { color: '#C6F093', offset: 0.5 },
      { color: '#88DB24', offset: 0.85 }, { color: '#88DB23', offset: 1.0 }])

  init() {
    CaloriesServiceApi.queryDietPlans().then((resp) => {
      this.dietPlanList = this.dietPlanList.filter(() => false)
      resp.forEach(item => {
        let dietPlanList =
          item.foodList.map(food => new FoodPlanCalories(food.id, food.name, food.weight, food.calories))
        this.dietPlanList.push(new DietPlans(item.id, item.menuId, item.name, item.desc, item.totalCalories,
          dietPlanList))
      })
    })
  }
}