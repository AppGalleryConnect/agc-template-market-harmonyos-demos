import { CommonConstants, RouterMap, RouterModule } from 'commonlib';
import { RecipeIngredient, RecipeStep } from 'network';
import { DishesVM } from '../viewModels/DishesVM';
import { promptAction } from '@kit.ArkUI';

@Builder
export function DishesPageBuilder() {
  DishesPage();
}

@ComponentV2
struct DishesPage {
  @Local vm: DishesVM = new DishesVM()

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll() {
          Column() {
            Image($r(`app.media.${this.vm.recipeDetail?.thumbnail}`)).width(CommonConstants.FULL_WIDTH)
            List({ scroller: this.vm.scroller }) {
              ListItem() {
                this.headerComp()
              }

              ListItem() {
                this.authorComp()
              }

              this.ingredientsComp()
              this.stepsComp()
            }.divider({ strokeWidth: 1 }).padding({ left: 16, right: 16 })
          }
        }.scrollBar(BarState.Off)

        Image($r('app.media.ic_basket')).width(40).height(40).onClick(() => {
          RouterModule.push({ url: RouterMap.SHOPPING_BASKET_PAGE })
        }).margin({ left: 16 })
      }.alignContent(Alignment.Start)

    }.title(this.vm.recipeDetail?.title)
  }

  @Builder
  headerComp() {
    Row() {
      Text(this.vm.recipeDetail?.title)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Row() {
        Image(this.vm.collection ? $r('app.media.ic_star') : $r('app.media.ic_star_fill')).width(24).height(24)
        Text(this.vm.collection ? '已收藏' : '收藏')
          .fontSize(10)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({ left: 8 })
      }.onClick(() => {
        this.vm.addCollection()
      })
    }
    .width(CommonConstants.FULL_WIDTH)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: 24, bottom: 24 })
  }

  @Builder
  authorComp() {
    Column() {
      Row() {
        Row() {
          Image($r(`app.media.${this.vm.recipeDetail?.authorAvatar}`)).width(40).height(40).borderRadius(20)
          Text(this.vm.recipeDetail?.author).fontSize(14).fontColor($r('sys.color.font_primary')).margin({ left: 4 })
        }

      }.width(CommonConstants.FULL_WIDTH).justifyContent(FlexAlign.SpaceBetween)

      Text(this.vm.recipeDetail?.description).fontSize(12).fontColor($r('sys.color.font_secondary')).margin({ top: 12 })
      Row() {
        Text('用料').fontSize(18).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
        Button('加入菜篮子', { controlSize: ControlSize.SMALL })
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .padding({
            top: 4,
            bottom: 4,
            left: 8,
            right: 8,
          })
          .backgroundColor('#0D000000')
          .onClick(() => {
            if (this.vm.recipeDetail) {
              this.vm.basketList.addBasket(this.vm.recipeDetail)
              promptAction.showToast({ message: '添加成功~！' })
            }
          })
      }.margin({ top: 24 }).width(CommonConstants.FULL_WIDTH).justifyContent(FlexAlign.SpaceBetween)
    }
    .width(CommonConstants.FULL_WIDTH)
    .padding({ top: 24, bottom: 12 })
    .alignItems(HorizontalAlign.Start)

  }

  @Builder
  ingredientsComp() {
    ForEach(this.vm.recipeDetail?.ingredients, (item: RecipeIngredient) => {
      ListItem() {
        Row({ space: 8 }) {
          Text(item.name).fontSize(12).fontColor($r('sys.color.font_primary')).layoutWeight(1)
          Text() {
            Span(item.quantity)
            Span(item.unit)
          }.fontSize(12).fontColor($r('sys.color.font_primary')).layoutWeight(1)
        }.padding({ top: 12, bottom: 12 }).width(CommonConstants.FULL_WIDTH)
      }
    })
  }

  @Builder
  stepsComp() {
    ForEach(this.vm.recipeDetail?.steps, (item: RecipeStep) => {
      ListItem() {
        Column() {
          Text(`步骤 ${item.stepNumber}`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .margin({ top: 4 })
          Image($r('app.media.img_step')).width(CommonConstants.FULL_WIDTH).borderRadius(16).margin({ top: 16 })
          Text(item.description).fontSize(14).fontColor($r('sys.color.font_primary')).margin({ top: 12 })
        }.padding({ top: 12, bottom: 12 }).width(CommonConstants.FULL_WIDTH).alignItems(HorizontalAlign.Start)
      }
    })
  }
}

