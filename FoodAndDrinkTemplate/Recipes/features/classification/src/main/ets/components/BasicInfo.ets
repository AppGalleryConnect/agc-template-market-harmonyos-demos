import { RouterMap, RouterModule } from 'commonlib';
import { RecipeIngredient } from 'network';
import { BasketItem } from 'shopping_basket';
import { CommentModel, Score } from '../model/CommentModel';
import { DishesVM } from '../viewModels/DishesVM';

@ComponentV2
export struct BasicInfo {
  @Local arr: Score[] = [
    new Score('0', true),
    new Score('1', false),
    new Score('2', false),
    new Score('3', false),
    new Score('4', false),
  ];
  @Param @Require dishesVm: DishesVM;
  @Param isShowDishModel: boolean = false;

  aboutToAppear(): void {

  }

  @Computed
  get isInBasket() {
    return this.dishesVm.basketList.list.some((item: BasketItem) => item.id === this.dishesVm.recipeDetail?.id);
  }

  build() {
    Column() {
      Row() {
        Text(this.dishesVm.recipeDetail?.title)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .layoutWeight(1)
      }
      .width('100%')
      .padding({
        top: 24,
        bottom: 24,
        left: 16,
        right: 16
      });

      Divider().strokeWidth('1px')

      // 博主信息
      Column() {
        Row() {
          Row() {
            Image($r(`app.media.${this.dishesVm.recipeDetail?.authorAvatar}`))
              .width(40)
              .height(40)
              .borderRadius(20);
            Text(this.dishesVm.recipeDetail?.author)
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 4 });
          }.onClick(() => {
            RouterModule.push(RouterMap.BLOGGER_PROFILE_PAGE,
              { 'id': this.dishesVm.recipeDetail?.authorId } as Record<string, number>)
          })

          Button(this.dishesVm.isFollower ? '已关注' : '关注', { controlSize: ControlSize.SMALL })
            .fontSize($r('sys.float.Body_M'))
            .fontColor(this.dishesVm.isFollower ? '#E84026' : $r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.dishesVm.isFollower ? '#33FD4238' : '#FD4238')
            .width(72)
            .onClick(() => {
              this.dishesVm.changeFollower(!this.dishesVm.isFollower)
            })
        }.width('100%').justifyContent(FlexAlign.SpaceBetween);

        Text(this.dishesVm.recipeDetail?.description)
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 12 });
      }
      .width('100%')
      .padding({ top: 24, left: 16, right: 16 })
      .alignItems(HorizontalAlign.Start);

      // 用料
      Column() {
        Row() {
          Text('用料').fontSize(18).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'));
        }
        .width('100%')

        Divider().strokeWidth('1px').margin({ top: 12 })
        ForEach(this.dishesVm.recipeDetail?.ingredients, (item: RecipeIngredient) => {
          Row({ space: 8 }) {
            Text(item.name).fontSize(12).fontColor($r('sys.color.font_primary')).layoutWeight(1);
            Text() {
              Span(item.quantity);
              Span(item.unit);
            }.fontSize(12).fontColor($r('sys.color.font_primary')).layoutWeight(1);
          }.padding({ top: 12, bottom: 12 }).width('100%');

          Divider().strokeWidth('1px')
        }, (item: RecipeIngredient, index) => item.name + item.quantity + item.unit);
      }
      .margin({ top: 24 })
      .padding({ left: 16, right: 16 })
    }
  }


}