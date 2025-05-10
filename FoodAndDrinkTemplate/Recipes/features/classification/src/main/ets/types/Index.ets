import { Type } from '@kit.ArkUI';
import { RecipeDetail, RecipeIngredient } from 'network';

const TAG = '[ShoppingBasketUtil]';

@ObservedV2
export class IngredientItem implements RecipeIngredient {
  @Trace name: string = ''
  @Trace quantity: string = ''
  @Trace unit: string = ''
  @Trace sum: string = '0'
  @Trace sumArr: string[] = []

  constructor(name: string = '', quantity: string = '', unit: string = '') {
    this.name = name
    this.quantity = quantity
    this.unit = unit
  }
}

@ObservedV2
export class BasketItem {
  id: number = 0
  title: string = ''
  @Trace showAddSheet: boolean = false
  @Type(IngredientItem)
  @Trace todoList: IngredientItem[] = []
  @Type(IngredientItem)
  @Trace finishedList: IngredientItem[] = []

  constructor(id: number = 0, title: string = '', todoList: IngredientItem[] = [],
    finishedList: IngredientItem[] = []) {
    this.id = id
    this.title = title
    this.todoList = todoList
    this.finishedList = finishedList
  }
}

@ObservedV2
export class BasketList {
  @Type(BasketItem)
  @Trace list: BasketItem[] = []
  @Trace id: number = 1

  constructor(list: BasketItem[] = []) {
    this.list = list
  }

  public addBasket(data: RecipeDetail) {
    let ingredients: IngredientItem[] =
      data.ingredients.map(item => new IngredientItem(item.name, item.quantity, item.unit))
    let basketItem: BasketItem = new BasketItem(this.id, data.title, ingredients)
    this.list.push(basketItem);
    this.id++
  }
}