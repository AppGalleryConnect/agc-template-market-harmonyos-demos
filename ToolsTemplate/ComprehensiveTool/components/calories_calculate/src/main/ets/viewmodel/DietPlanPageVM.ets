import { componentUtils } from '@kit.ArkUI';
import { getInstance } from '../common/RouteStack';
import { FoodPlanCaloriesBody, CustomFoodBody } from '../model/Calories';
import { FoodCalories, FoodCategory, RouterMap } from '../model/Index';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { CaloriesServiceApi } from '../https/apis/CaloriesService';

@ObservedV2
export class DietPlanPageVM {
  @Trace foodCategories: FoodCategory[] = [];
  @Trace currentIndex: number = 0;
  @Trace selectFoods: FoodCalories[] = [];
  @Trace menuId: number = 0;
  @Trace selectIndex: number = 0;
  @Trace selectText: ResourceStr = '';
  @Trace searchText: string = '';
  @Trace inputName: string = '';
  @Trace inputWeight: string = '';
  @Trace inputCalories: string = '';
  @Trace showAddFoodSheet: boolean = false;
  @Trace inputText: string = '';
  @Trace isLocalRefresh: boolean = false;
  @Trace height: number = 0;
  @Trace blankNumber: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  submitLoading: boolean = false;
  titleItemScroller: Scroller = new Scroller();
  scroller: Scroller = new Scroller();
  menuList: Array<SelectOption> = [
    { value: '早餐', icon: $r('app.media.ic_checked') },
    { value: '午餐', icon: $r('app.media.ic_checked') },
    { value: '晚餐', icon: $r('app.media.ic_checked') },
    { value: '上午加餐', icon: $r('app.media.ic_checked') },
    { value: '中午加餐', icon: $r('app.media.ic_checked') },
    { value: '晚上加餐', icon: $r('app.media.ic_checked') }];
  keyboardList: Array<string> = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '.'];

  getBarInfo(uiContext: UIContext) {
    let obj: componentUtils.ComponentInfo = uiContext.getComponentUtils().getRectangleById(`sliderOne`);
    this.height = uiContext.px2vp(obj.size.height);
    this.getBlank();
  }

  getBlank(count: number = 4) {
    let arrNumber = (this.height - 14 - 48 * count) / 48;
    const arr: number[] = [];
    for (let i = 1; i <= arrNumber; i++) {
      arr.push(i);
    }

    this.blankNumber = arr;
  }

  init() {
    this.selectFoods = [];
    CaloriesServiceApi.queryFoodCategory().then(res => {
      this.foodCategories = this.foodCategories.filter(() => false);
      res.forEach(item => {
        let foodList =
          item.foodList.map(food => new FoodCalories(food.id, food.name, food.category, food.weight, food.calories));
        this.foodCategories.push(new FoodCategory(item.id, item.name, foodList));
      });
      if (!this.isLocalRefresh) {
        let params = getInstance().getParamByName(RouterMap.DIET_PLAN_PAGE)[0] as Record<string, number>;
        if (params?.id !== undefined) {
          this.menuId = params.id;
          this.selectIndex = params?.id || 0;
        }
      }
      CaloriesServiceApi.queryDietPlan(this.menuId).then(resp => {
        this.selectIndex = this.menuList.findIndex(item => item.value === resp.name);
        this.selectText = resp.name;
        res.forEach(item => {
          item.foodList.forEach(food => {
            if (resp.foodList.some(plan => plan.name === food.name) &&
              !this.selectFoods.some(selectFood => selectFood.id === food.id)) {
              this.selectFoods.push(new FoodCalories(food.id, food.name, food.category, food.weight,
                food.calories));
            }
          });
        });
      });
      this.selectText = this.menuList[this.selectIndex].value;
    });
  }

  // 下标索引处理
  currentIndexChangeAction(index: number, isClassify: boolean): void {
    if (this.currentIndex !== index) {
      this.currentIndex = index;
      if (isClassify) {
        this.scroller.scrollToIndex(index);
      } else {
        this.titleItemScroller.scrollToIndex(index);
      }
    }
  }

  changeFood(food: FoodCalories) {
    if (this.selectFoods.some(item => item.id === food.id)) {
      this.selectFoods = this.selectFoods.filter(item => item.id !== food.id);
    } else {
      this.selectFoods.push(food);
    }
  }

  addDietPlan() {
    if (this.submitLoading) {
      return;
    }
    this.submitLoading = true;
    let data: FoodPlanCaloriesBody[] = this.selectFoods.map(item => {
      let food: FoodPlanCaloriesBody = {
        id: item.id,
        name: item.name,
        weight: item.weight ?? 100,
        calories: item.calories,
      };
      return food;
    });
    CaloriesServiceApi.addDietPlans(this.selectIndex, this.selectText.toString(), data).then(res => {
      getInstance().pop();
    }).catch(() => {
      promptAction.showToast({ message: '添加失败~' });
    }).finally(() => {
      this.submitLoading = false;
    });
  }

  confirmBtn() {
    if (this.submitLoading) {
      return;
    }
    if (!this.inputName) {
      promptAction.showToast({ message: '输入食品名称' });
      return;
    }
    if (!this.checkAddCustomFood(this.inputName)) {
      promptAction.showToast({ message: '食品已添加' });
      return;
    }
    if (!this.inputWeight) {
      promptAction.showToast({ message: '输入食品重量（克 /毫升）' });
      return;
    }
    if (!this.inputCalories) {
      promptAction.showToast({ message: '输入食品热量（千卡）' });
      return;
    }
    let data: CustomFoodBody = {
      name: this.inputName,
      weight: Number(this.inputWeight),
      calories: Number(this.inputCalories),
    };
    CaloriesServiceApi.addCustomFood(data).then((res) => {
      this.init();
      this.showAddFoodSheet = false;
    }).finally(() => {
      this.submitLoading = false;
    });
  }

  checkAddCustomFood(value: string) {
    let isRepeat = true;
    for (let category of this.foodCategories) {
      if (!isRepeat) {
        break;
      }
      for (let food of category.foodList) {
        if (food.name === value) {
          isRepeat = false;
          break;
        }
      }
    }
    return isRepeat;
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

  confirmSelectBtn(item: FoodCalories) {
    let data: FoodPlanCaloriesBody[] = [{
      id: item.id,
      name: item.name,
      weight: Number(this.inputText) || 100,
      calories: item.calories,
    }];
    CaloriesServiceApi.addDietPlans(this.selectIndex, this.selectText.toString(), data).then(res => {
      getInstance().pop('success');
      this.showAddFoodSheet = false;
    }).catch(() => {
      promptAction.showToast({ message: '添加失败~' });
    });
  }
}