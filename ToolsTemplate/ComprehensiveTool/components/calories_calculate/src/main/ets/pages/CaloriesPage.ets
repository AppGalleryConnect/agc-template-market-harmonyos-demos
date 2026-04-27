import { CalorieCalculation } from '../components/CalorieCalculation';
import { CaloriesPageVM } from '../viewmodel/CaloriesPageVM';
import { AvoidAreaUtil } from '../util/AvoidAreaUtil'
import { setPathStack, getInstance } from '../common/RouteStack';

@Builder
export function CaloriesPageBuilder() {
  CaloriesPage();
}

@ComponentV2
struct CaloriesPage {
  @Local vm: CaloriesPageVM = new CaloriesPageVM();

  @Computed
  get todayCalories() {
    let todayCalories = 0;
    this.vm.dietPlanList.forEach(item => {
      todayCalories += item.totalCalories;
    });
    return todayCalories;
  }

  build() {
    NavDestination() {
      Column() {
        CalorieCalculation({
          seriesData: this.vm.seriesData,
          dietPlanList: this.vm.dietPlanList,
          addMeal: (id: number, isModify?: boolean) => {
            let data: Record<string, number> = { 'id': id };
            if (isModify) {
              let menuId = this.vm.dietPlanList.find(item => item.menuId === id)?.menuId;
              data = { 'id': menuId! };
            }
            getInstance().pushPathByName('DietPlanPage', data, (popInfo: PopInfo) => {
              this.vm.init();
            })
          },
        });
      };
    }
    .title('热量计算')
    .padding({ top: AvoidAreaUtil.getTopHeight() })
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((ctx) => {
      setPathStack(ctx.pathStack);
    })
    .onShown(() => {
      this.vm.init();
    })
  }
}
