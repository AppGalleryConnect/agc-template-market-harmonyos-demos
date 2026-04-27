import { promptAction } from '@kit.ArkUI';
import { getInstance } from '../common/RouteStack';
import { FoodCalories, FoodPlanCaloriesBody } from '../model/Calories';
import { RouterMap } from '../model/Index';
import { CaloriesServiceApi } from '../https/apis/CaloriesService';

@ObservedV2
export class SearchFoodPageVM {
  @Trace searchResul: FoodCalories[] = [];
  @Trace searchText: string = '';
  @Trace showAddFoodSheet: boolean = false;
  @Trace selectIndex: number = 0;
  @Trace selectText: ResourceStr = '早餐';
  @Trace inputText: string = '';
  @Trace foodCalories: FoodCalories | undefined = undefined;
  @Trace dietPlanList: FoodPlanCaloriesBody[] = [];
  menuList: Array<SelectOption> = [
    { value: '早餐', icon: $r('app.media.ic_checked') },
    { value: '午餐', icon: $r('app.media.ic_checked') },
    { value: '晚餐', icon: $r('app.media.ic_checked') },
    { value: '上午加餐', icon: $r('app.media.ic_checked') },
    { value: '中午加餐', icon: $r('app.media.ic_checked') },
    { value: '晚上加餐', icon: $r('app.media.ic_checked') }];
  keyboardList: Array<string> = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '.'];

  init() {
    let params = getInstance().getParamByName(RouterMap.SEARCH_FOOD_PAGE)[0] as Record<string, number>;
    this.selectIndex = params?.id || 0;
    this.selectText = this.menuList[this.selectIndex].value;

    CaloriesServiceApi.queryDietPlans().then((resp) => {
      resp.forEach(item => {
        if (this.selectIndex === item.menuId) {
          this.dietPlanList = item.foodList;
        }
      });
    });
  }

  searchFood() {
    if (!this.searchText) {
      return;
    }
    CaloriesServiceApi.searchFoodByName(this.searchText).then(res => {
      this.searchResul = this.searchResul.filter(() => false);
      this.searchResul = res;
    });
  }

  btnClick(item: string) {
    if (item === '.' && this.inputText.includes('.')) {
      return;
    }
    if (this.inputText.includes('.') && this.inputText.substring(this.inputText.indexOf('.') + 1).length >= 2) {
      return;
    }
    if (item !== '.' && !this.inputText.includes('.') && Number(this.inputText) === Number(this.inputText + item)) {
      return;
    }
    if (Number(this.inputText + item) > 9999) {
      return;
    }
    this.inputText = this.inputText + item;
  }

  deleteBtn() {
    if (this.inputText.length) {
      this.inputText = this.inputText.substring(0, this.inputText.length - 1);
    }
  }

  confirmBtn(item: FoodCalories, uiContext: UIContext) {
    let data: FoodPlanCaloriesBody[] = this.dietPlanList;
    data.push({
      id: item.id,
      name: item.name,
      weight: Number(this.inputText) || 100,
      calories: Number((item.calories / 100 * (Number(this.inputText) ? Number(this.inputText) : 100)).toFixed(2)),
    });
    CaloriesServiceApi.addDietPlans(this.selectIndex, this.selectText.toString(), data).then(() => {
      getInstance().pop('success');
      this.showAddFoodSheet = false;
    }).catch(() => {
      uiContext.getPromptAction().showToast({ message: '添加失败~' });
    });
  }
}