import { BreakpointModel, BreakpointType, RouterMap, RouterModule } from 'commonlib';
import { addDietPlans, FoodPlanCaloriesBody, searchFoodByName } from 'network';
import { FoodCalories } from '../types/Index';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class SearchFoodPageVM {
  @Trace searchResul: FoodCalories[] = []
  @Trace isShowArray: boolean[] = []
  @Trace searchText: string = ''
  @Trace selectFoods: FoodCalories[] = []
  @Trace selectIndex: number = 0
  @Trace selectText: ResourceStr = '早餐'
  @Trace inputText: string = ''
  menuList: Array<SelectOption> = [
    { value: '早餐', icon: $r('app.media.ic_checked') },
    { value: '午餐', icon: $r('app.media.ic_checked') },
    { value: '晚餐', icon: $r('app.media.ic_checked') },
    { value: '上午加餐', icon: $r('app.media.ic_checked') },
    { value: '中午加餐', icon: $r('app.media.ic_checked') },
    { value: '晚上加餐', icon: $r('app.media.ic_checked') }]
  keyboardList: Array<string> = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0']

  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get getWidth() {
    if(this.breakPointModel.currentBreakpoint === 'sm') {
      return 72
    }
    return 100
  }

  @Computed
  get getHeight() {
    if(this.breakPointModel.currentBreakpoint === 'sm') {
      return 48
    }
    return 62
  }

  init() {
    let params = RouterModule.getNavParam<Record<string, object>>(RouterMap.SEARCH_FOOD_PAGE)
    this.selectFoods = (params?.selectFoods as FoodCalories[] | undefined) ?? []
    this.selectIndex = Number(params?.id || 0)
    this.selectText = this.menuList[this.selectIndex].value
  }

  searchFood() {
    if (!this.searchText) {
      return
    }
    searchFoodByName(this.searchText).then(res => {
      this.searchResul = this.searchResul.filter(() => false)
      if (res.status === 200) {
        this.searchResul = res.data
        this.isShowArray = []
        this.searchResul.forEach((item: FoodCalories, index: number) => {
          this.isShowArray.push(false)
        })
      }
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

  confirmBtn(item: FoodCalories, index: number) {
    let weight =
      (item.calories / Number(item.weight ?? 100) * Number(this.inputText === '' ? 100 : this.inputText)).toFixed(2);
    this.selectFoods = this.selectFoods.filter(i => i.name !== item.name)
    let data: FoodPlanCaloriesBody[] = this.selectFoods.map(item => {
      let food: FoodPlanCaloriesBody = {
        id: item.id,
        name: item.name,
        weight: item.weight ?? 100,
        calories: item.calories,
      }
      return food
    })
    let playData: FoodPlanCaloriesBody = {
      id: item.id,
      name: item.name,
      weight: Number(this.inputText) || 100,
      calories: Number(weight),
    }
    data.push(playData)
    addDietPlans(this.selectIndex, this.selectText.toString(), data).then(res => {
      if (res.status === 200) {
        this.isShowArray[index] = false
        RouterModule.push(RouterMap.CALORIES_PAGE)
      } else {
        promptAction.showToast({ message: '添加失败~' })
      }
    })
  }
}