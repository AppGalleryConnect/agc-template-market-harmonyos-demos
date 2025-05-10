import { AppStorageMap } from 'commonlib';
import { BasketItem, BasketList, IngredientItem } from '../types/Index';
import { PersistenceV2 } from '@kit.ArkUI';
import { Decimal } from '@kit.ArkTS';

const TAG = '[ShoppingBasketPageVM]';

@ObservedV2
export class ShoppingBasketPageVM {
  @Trace basketList: BasketList =
    PersistenceV2.connect(BasketList, AppStorageMap.SHOPPING_BASKET, () => new BasketList())!;

  @Computed
  get todoList() {
    let todoListTemp: IngredientItem[] = []
    this.basketList.list.forEach(item => {
      item.todoList.forEach(todo => {
        let existItem = todoListTemp.find(i => i.name === todo.name)
        if (existItem) {
          if (existItem.unit) {
            existItem.sum = new Decimal(existItem.sum).add(todo.quantity).toString()
          } else {
            existItem.sumArr.push(todo.name)
          }
        } else {
          if (todo.unit) {
            todo.sum = todo.quantity
            todoListTemp.push(todo)
          } else {
            todo.sumArr.push(todo.name)
            todoListTemp.push(todo)
          }
        }
      })
    })
    return todoListTemp
  }

  @Computed
  get finishedList() {
    let finishedListTemp: IngredientItem[] = []
    this.basketList.list.forEach(item => {
      item.finishedList.forEach(todo => {
        let noFinished = this.todoList.some(i => i.name === todo.name)
        if (!noFinished) {
          let existItem = finishedListTemp.some(i => i.name === todo.name)
          if (!existItem) {
            finishedListTemp.push(todo)
          }
        }
      })
    })
    return finishedListTemp
  }

  @Trace ingredientsTab: number = 1
  @Trace isExpand: boolean = true
  customDialogComponentId: number = 0
  scroller: Scroller = new Scroller();
  private static _instance: ShoppingBasketPageVM;

  public static get instance() {
    if (!ShoppingBasketPageVM._instance) {
      ShoppingBasketPageVM._instance = new ShoppingBasketPageVM();
    }
    return ShoppingBasketPageVM._instance;
  }

  init(): void {
  }

  todoCb(item: IngredientItem) {
    this.basketList.list.forEach(basket => {
      basket.todoList = basket.todoList.filter(i => i.name !== item.name)
      basket.finishedList.push(item)
    })
  }

  finishedCb(item: IngredientItem) {
    this.basketList.list.forEach(basket => {
      basket.finishedList = basket.finishedList.filter(i => i.name !== item.name)
      basket.todoList.push(item)
    })
  }

  removeRecipe(item: BasketItem) {
    this.basketList.list = this.basketList.list.filter(i => i.id !== item.id)
  }
}
