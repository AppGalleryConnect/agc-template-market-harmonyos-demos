import { DietPlans } from '../model/Index';
import { CaloriesSummary } from './CaloriesSummary';
import { FoodDiary } from './FoodDiary';

@Preview
@ComponentV2
export struct CalorieCalculation {
  @Param seriesData: number[] = [];
  @Param dietPlanList: DietPlans[] = []
  @Event addMeal: (id: number, isModify?: boolean) => void = () => {
  }

  @Computed
  get todayCalories() {
    let todayCalories = 0
    this.dietPlanList.forEach(item => {
      todayCalories += item.totalCalories
    })
    return Number(todayCalories.toFixed(2))
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        CaloriesSummary({ todayCalories: this.todayCalories, seriesData: this.seriesData })
        FoodDiary({
          dietPlanList: this.dietPlanList,
          addMeal: (id: number, isModify?: boolean) => {
            this.addMeal(id, isModify)
          },
        })
      }
    }
    .scrollBar(BarState.Off)
    .padding(16)
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
    .align(Alignment.Top)
  }
}
