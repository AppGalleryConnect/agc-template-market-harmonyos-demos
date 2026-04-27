import { MenuItemBuilder } from '../components/MenuItemBuilder';

@ObservedV2
export class  FoodCalories {
  @Trace id: number = 0;
  @Trace name: string = '';
  @Trace category: string = '';
  @Trace weight?: number = 100;
  @Trace calories: number = 0;

  constructor(id: number = 0, name: string = '', category: string = '', weight: number = 100, calories: number = 0) {
    this.id = id;
    this.name = name;
    this.category = category;
    this.weight = weight;
    this.calories = calories;
  }
}
@ObservedV2
export class FoodCategory {
  @Trace id: number = 0;
  @Trace name: string= '';
  @Trace foodList: Array<FoodCalories> = [];

  constructor(id: number = 0, name: string= '', foodList: Array<FoodCalories> = []) {
    this.id = id;
    this.name = name;
    this.foodList = foodList;
  }
}

export class MyMenuItem implements ContentModifier<MenuItemConfiguration> {
  applyContent(): WrappedBuilder<[MenuItemConfiguration]> {
    return wrapBuilder(MenuItemBuilder)
  }
}

export enum SummaryIndexEnum {
  DAY = 1,
  WEEK
}

export const xMap: Record<number, string> = {
  0: '周一',
  1: '周二',
  2: '周三',
  3: '周四',
  4: '周五',
  5: '周六',
  6: '周日',
}

export enum RouterMap {
  DIET_PLAN_PAGE = 'DietPlanPage',
  SEARCH_FOOD_PAGE = 'SearchFoodPage'
}

@ObservedV2
export class DailyMeals {
  id: number = 0
  icon: ResourceStr = ''
  title: ResourceStr = ''
  @Trace isFinished: boolean = false

  constructor(id: number = 0, icon: ResourceStr = '', title: ResourceStr = '', isFinished: boolean = false) {
    this.id = id
    this.icon = icon
    this.title = title
    this.isFinished = isFinished
  }
}

@ObservedV2
export class FoodPlanCalories {
  @Trace id: number;
  @Trace name: string;
  @Trace weight: number
  @Trace calories: number;

  constructor(id: number, name: string, weight: number, calories: number) {
    this.id = id
    this.name = name
    this.weight = weight
    this.calories = calories
  }
}

@ObservedV2
export class DietPlans {
  @Trace id: number;
  @Trace menuId: number;
  @Trace name: string;
  @Trace desc: string
  @Trace totalCalories: number
  @Trace foodList: FoodPlanCalories[]

  constructor(id: number, menuId: number, name: string, desc: string, totalCalories: number,
    foodList: FoodPlanCalories[]) {
    this.id = id
    this.menuId = menuId
    this.name = name
    this.desc = desc
    this.totalCalories = totalCalories
    this.foodList = foodList
  }
}

export enum AddMealEnum {
  ADD_MEAL = 99,
  BREAKFAST = 0,
  LUNCH,
  DINNER,
  ADD_BREAKFAST,
  ADD_LUNCH,
  ADD_DINNER,

}

export enum TabIndexEnum {
  FIRST = 1,
  SECOND
}
