import { CalorieCalculation } from 'calorie_calculation';
import { RouterMap, RouterModule } from 'commonlib';
import { CaloriesPageVM } from '../viewModels/CaloriesPageVM';

@Builder
export function CaloriesPageBuilder() {
  CaloriesPage()
}

@ComponentV2
struct CaloriesPage {
  @Local vm: CaloriesPageVM = new CaloriesPageVM();

  @Computed
  get todayCalories() {
    let todayCalories = 0
    this.vm.dietPlanList.forEach(item => {
      todayCalories += item.totalCalories
    })
    return todayCalories
  }

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      CalorieCalculation({
        seriesData: this.vm.seriesData,
        dietPlanList: this.vm.dietPlanList,
        addMeal: (id: number, isModify?: boolean) => {
          let data: Record<string, number> = { 'id': id }
          if (isModify) {
            let menuId = this.vm.dietPlanList.find(item => item.menuId === id)?.menuId
            data = { 'menuId': menuId! }
          }
          RouterModule.push(RouterMap.DIET_PLAN_PAGE, data, (popInfo: PopInfo) => {
            this.vm.init()
          })
        },
      })
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
    .title('热量计算')
    .padding({top: 40})
    .onBackPressed(() => {
      let param: Record<string, Object> = {};
      param.todayCalories = this.todayCalories;
      RouterModule.pop(param)
      return true;
    })
  }
}
