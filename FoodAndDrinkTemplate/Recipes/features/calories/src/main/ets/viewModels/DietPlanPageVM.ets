import { BreakpointModel, BreakpointType, RouterMap, RouterModule } from 'commonlib';
import {
  addCustomFood,
  addDietPlans,
  clearDietPlans,
  CustomFoodBody,
  FoodPlanCaloriesBody,
  queryDietPlan,
  queryFoodCategory,
} from 'network';
import { FoodCalories, FoodCategory } from '../types/Index';
import { AppStorageV2 } from '@kit.ArkUI';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';

@ObservedV2
export class DietPlanPageVM {
  @Trace foodCategories: FoodCategory[] = []
  @Trace currentIndex: number = 0
  @Trace selectFoods: FoodCalories[] = []
  @Trace menuId: number | undefined = undefined
  @Trace selectIndex: number = 0
  @Trace selectText: ResourceStr = ''
  @Trace searchText: string = ''
  @Trace inputName: string = ''
  @Trace inputWeight: string = ''
  @Trace inputCalories: string = ''
  @Trace showAddFoodSheet: boolean = false
  @Trace inputText: string = ''
  @Trace showCheckedFoods: boolean = false;
  submitLoading: boolean = false
  titleItemScroller: Scroller = new Scroller();
  scroller: Scroller = new Scroller();
  checkedScroller: Scroller = new Scroller();
  menuList: Array<SelectOption> = [
    { value: '早餐', icon: $r('app.media.ic_checked') },
    { value: '午餐', icon: $r('app.media.ic_checked') },
    { value: '晚餐', icon: $r('app.media.ic_checked') },
    { value: '上午加餐', icon: $r('app.media.ic_checked') },
    { value: '中午加餐', icon: $r('app.media.ic_checked') },
    { value: '晚上加餐', icon: $r('app.media.ic_checked') }]
  keyboardList: Array<string> = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '.']
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 2,
    xl: 2,
  });
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  init() {
    queryFoodCategory().then(res => {
      this.foodCategories = this.foodCategories.filter(() => false)
      if (res.status === 200) {
        res.data.forEach(item => {
          let foodList =
            item.foodList.map(food => new FoodCalories(food.id, food.name, food.category, food.weight, food.calories))
          this.foodCategories.push(new FoodCategory(item.id, item.name, foodList))
        })
        let params = RouterModule.getNavParam<Record<string, number>>(RouterMap.DIET_PLAN_PAGE)
        if (params?.menuId !== undefined) {
          this.menuId = params.menuId
          queryDietPlan(this.menuId).then(resp => {
            if (resp.status === 200 && resp.data) {
              this.selectIndex = this.menuList.findIndex(item => item.value === resp.data.name)
              this.selectText = resp.data.name
              res.data.forEach(item => {
                item.foodList.forEach(food => {
                  if (resp.data.foodList.some(plan => plan.name === food.name) &&
                    !this.selectFoods.some(selectFood => selectFood.id === food.id)) {
                    this.selectFoods.push(new FoodCalories(food.id, food.name, food.category, food.weight,
                      food.calories))
                  }
                })
              })
            }
          })
        } else {
          this.selectIndex = params?.id || 0
        }
        this.selectText = this.menuList[this.selectIndex].value
      }
    })
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
      this.selectFoods = this.selectFoods.filter(item => item.id !== food.id)
    } else {
      this.selectFoods.push(food)
    }
  }

  addDietPlan() {
    if (this.submitLoading) {
      return
    }
    this.submitLoading = true
    let data: FoodPlanCaloriesBody[] = this.selectFoods.map(item => {
      let food: FoodPlanCaloriesBody = {
        id: item.id,
        name: item.name,
        weight: item.weight ?? 100,
        calories: item.calories,
      }
      return food
    })
    addDietPlans(this.selectIndex, this.selectText.toString(), data).then(res => {
      if (res.status === 200) {
        RouterModule.pop('success')
      } else {
        promptAction.showToast({ message: '添加失败~' })
      }
    }).finally(() => {
      this.submitLoading = false
    })
  }
  clearDietPlan() {
    this.submitLoading = true
    clearDietPlans().then(res => {
      if (res.status === 200) {
        RouterModule.pop('success')
      } else {
        promptAction.showToast({ message: '已清除~' })
      }
    }).finally(() => {
      this.submitLoading = false
    })
  }
  confirmBtn() {
    if (this.submitLoading) {
      return
    }
    if (!this.inputName) {
      promptAction.showToast({ message: '输入食品名称' })
      return
    }
    if (!this.inputWeight) {
      promptAction.showToast({ message: '输入食品重量（克 /毫升）' })
      return
    }
    if (!this.inputCalories) {
      promptAction.showToast({ message: '输入食品热量（千卡）' })
      return
    }
    let data: CustomFoodBody = {
      name: this.inputName,
      weight: Number(this.inputWeight),
      calories: Number(this.inputCalories),
    }
    addCustomFood(data).then((res) => {
      if (res.status === 200) {
        this.init()
        this.showAddFoodSheet = false
      }
    }).finally(() => {
      this.submitLoading = false
    })
  }

  btnClick(item: string) {
    if (item === '.' && this.inputText.includes('.')) {
      return
    }
    if (this.inputText.includes('.') && this.inputText.substring(this.inputText.indexOf('.') + 1).length >= 2) {
      return
    }
    if (item !== '.' && !this.inputText.includes('.') && Number(this.inputText) === Number(this.inputText + item)) {
      return
    }
    if (Number(this.inputText + item) > 9999) {
      return
    }
    this.inputText = this.inputText + item
  }

  deleteBtn() {
    if (this.inputText.length) {
      this.inputText = this.inputText.substring(0, this.inputText.length - 1)
    }
  }

  confirmSelectBtn(item: FoodCalories) {
    let data: FoodPlanCaloriesBody[] = [{
      id: item.id,
      name: item.name,
      weight: Number(this.inputText) || 100,
      calories: item.calories,
    }]
    addDietPlans(this.selectIndex, this.selectText.toString(), data).then(res => {
      if (res.status === 200) {
        RouterModule.pop('success')
        this.showAddFoodSheet = false
      } else {
        promptAction.showToast({ message: '添加失败~' })
      }
    })
  }

  @Computed
  get getLines() {
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }
}