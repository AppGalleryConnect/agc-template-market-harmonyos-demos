import { CommonConstants, Logger } from 'commonlib';
import { ComponentContent, LengthMetrics } from '@kit.ArkUI';
import { DishesVM } from '../viewModels/DishesVM';
import { DishesStep } from './DishesStep';
import { RecipeDetail, RecipeIngredient } from 'network';

@Builder
export function DishesModePageBuilder() {
  DishesModePage();
}

@ComponentV2
struct DishesModePage {
  @Local vm: DishesVM = new DishesVM();
  @Local showMaterialSheet: boolean = false;

  aboutToAppear(): void {
    this.vm.init();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          DishesStep({ dishesVm: this.vm, isShowDishModel: false })
        }.padding({ bottom: 40 }) // ← 底部内边距占位
      }
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .title(this.buildTitleBar('烹饪模式'), { paddingStart: LengthMetrics.vp(16) })
    .padding({ top: CommonConstants.STATUS_BAR_HEIGHT })
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_gray'))
  }

  @Builder
  buildTitleBar(title: string) {
    Row() {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
        .fontColor($r('sys.color.font_primary'))

      Button('用料', { controlSize: ControlSize.SMALL })
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor($r('sys.color.comp_background_primary'))
        .padding({
          left: 16,
          right: 16,
          top: 10,
          bottom: 10
        })
        .borderRadius(20)
        .bindSheet($$this.showMaterialSheet, this.materialSheet(this.vm.recipeDetail!), {
          blurStyle: BlurStyle.Thick,
          height: SheetSize.FIT_CONTENT,
          preferType: SheetType.CENTER,
          showClose: true,
          onWillDismiss: (action: DismissSheetAction) => {
            this.showMaterialSheet = false
          }
        })
        .onClick(() => {
          this.showMaterialSheet = true
        });
    }
    .height(56)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 8, right: 12 })
  }

  @Builder
  materialSheet(recipeDetail: RecipeDetail) {
    Column() {
      Row() {
        Text('用料')
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(56)

      Divider().strokeWidth('1px').margin({ top: 12 })
      ForEach(recipeDetail?.ingredients, (item: RecipeIngredient) => {
        Row({ space: 8 }) {
          Text(item.name).fontSize(12).fontColor($r('sys.color.font_primary')).layoutWeight(1);
          Text() {
            Span(item.quantity);
            Span(item.unit);
          }.fontSize(12).fontColor($r('sys.color.font_primary')).layoutWeight(1);
        }.padding({ top: 12, bottom: 12 }).width('100%');

        Divider().strokeWidth('1px')
      }, (item: RecipeIngredient) => item.name + item.quantity + item.unit);
    }
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 16
    })
    .width('100%')
  }
}

