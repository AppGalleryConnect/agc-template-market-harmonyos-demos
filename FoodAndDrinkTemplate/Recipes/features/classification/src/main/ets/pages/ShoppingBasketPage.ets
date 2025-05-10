import { CommonConstants } from 'commonlib';
import { IngredientsComp, RecipeIngredientsComp } from '../components/IngredientsComp';
import { IngredientsTab } from '../constants/Enums';
import { IngredientItem } from '../types/Index';
import { ShoppingBasketPageVM } from '../viewModels/ShoppingBasketPageVM';

@Builder
export function ShoppingBasketPageBuilder() {
  ShoppingBasketPage();
}

@ComponentV2
struct ShoppingBasketPage {
  @Local vm: ShoppingBasketPageVM = ShoppingBasketPageVM.instance

  build() {
    NavDestination() {
      Row() {
        Text('全部用料')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.vm.ingredientsTab === IngredientsTab.ALL ? $r('sys.color.font_primary') :
          $r('sys.color.font_secondary'))
          .backgroundColor(this.vm.ingredientsTab === IngredientsTab.ALL ? $r('sys.color.background_primary') :
            '#00000000')
          .borderRadius(18)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ top: 8, bottom: 8 })
          .onClick(() => {
            this.vm.ingredientsTab = IngredientsTab.ALL
          })
        Text('菜谱用料')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.vm.ingredientsTab === IngredientsTab.RECIPE ? $r('sys.color.font_primary') :
          $r('sys.color.font_secondary'))
          .backgroundColor(this.vm.ingredientsTab === IngredientsTab.RECIPE ? $r('sys.color.background_primary') :
            '#00000000')
          .borderRadius(18)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ top: 8, bottom: 8 })
          .onClick(() => {
            this.vm.ingredientsTab = IngredientsTab.RECIPE
          })
      }
      .padding(2)
      .margin({
        top: 12,
        left: 16,
        right: 16,
        bottom: this.vm.basketList.list.length ? 0 : 12,
      })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(20)

      Scroll() {
        if (this.vm.basketList.list.length) {
          Column() {
            IngredientsComp({
              todoList: this.vm.todoList,
              finishedList: this.vm.finishedList,
              isAllTab: true,
              todoCb: (item: IngredientItem) => {
                this.vm.todoCb(item)
              },
              finishedCb: (item: IngredientItem) => {
                this.vm.finishedCb(item)
              },
            })
              .backgroundColor($r('sys.color.background_primary'))
              .padding({ left: 16, right: 16 })
              .visibility(this.vm.ingredientsTab === IngredientsTab.ALL ? Visibility.Visible : Visibility.None)
            RecipeIngredientsComp({ vm: this.vm })
              .visibility(this.vm.ingredientsTab === IngredientsTab.RECIPE ? Visibility.Visible : Visibility.None)
          }.layoutWeight(1)
        } else {
          Column() {
            Image($r('app.media.ic_empty')).size({ width: 160, height: 160 });
            Text('~~空空如也~~').fontSize(12).margin({ top: 24 }).opacity(0.6);
          }.margin({ top: 72 }).width(CommonConstants.FULL_WIDTH)
        }
      }
      .scrollBar(BarState.Off)
      .backgroundColor(this.vm.ingredientsTab === IngredientsTab.ALL || !this.vm.basketList.list.length ?
      $r('sys.color.background_primary') :
      $r('sys.color.background_secondary'))
      .layoutWeight(1)
      .align(Alignment.Top)
    }.title('菜篮子').onWillAppear(() => {
      this.vm.init()
    })
  }
}

