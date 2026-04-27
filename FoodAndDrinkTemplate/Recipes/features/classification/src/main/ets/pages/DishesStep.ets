import { RouterMap, RouterModule } from 'commonlib';
import { RecipeStep } from 'network';
import { DishesVM } from '../viewModels/DishesVM';

@ComponentV2
export struct DishesStep {
  @Param @Require dishesVm: DishesVM;
  @Param isShowDishModel: boolean = false;

  build() {
    Column() {
      ForEach(this.dishesVm.recipeDetail?.steps, (item: RecipeStep) => {
        Column() {
          Row() {
            Text(`步骤 ${item.stepNumber}`)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .margin({ top: 4 });

            if(item.stepNumber === 1 && this.isShowDishModel) {
              Button('烹饪模式', { controlSize: ControlSize.SMALL })
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .padding({
                  left: 8,
                  right: 8,
                })
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .onClick(() => {
                  RouterModule.push(RouterMap.DISHES_MODE,
                    { 'id': this.dishesVm.recipeDetail?.id } as Record<string, number>)
                });
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          if(item.stepImg?.startsWith('file://')) {
            Image(item.stepImg)
              .imageStyles(this.isShowDishModel)
          } else {
            Image(item.stepImg ? $r(`app.media.${item.stepImg}`) : $r('app.media.img_step'))
              .imageStyles(this.isShowDishModel)
          }
          Text(item.description)
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .margin({ top: 12 });
        }
        .padding({ top: 12, bottom: 12 })
        .width('100%')
        .alignItems(HorizontalAlign.Start);

        Divider().strokeWidth('1px')
      }, (item: RecipeStep, index) => item.stepNumber + item.description);
    }
    .margin({ left: this.dishesVm.breakPoint === 'sm' ? 0 : 12 })
    .padding({ left: 16, right: 16})
  }
}
@Extend(Image)
function imageStyles(isShowDishModel: boolean) {
  .size({ width: isShowDishModel ? '100%' : 120, height: isShowDishModel ? 305 : 100 })
  .borderRadius(16)
  .margin({ top: 16 })
}