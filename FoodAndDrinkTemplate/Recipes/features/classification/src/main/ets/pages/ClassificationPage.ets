import { ClassificationVM } from '../viewModels/ClassificationVM';
import { CommonConstants, HeaderMenuBuilder, RouterMap, RouterModule } from 'commonlib';
import { LinkCategory } from 'link_category';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';

@Builder
export function ClassificationPageBuilder() {
  ClassificationPage();
}

@ComponentV2
struct ClassificationPage {
  vm: ClassificationVM = ClassificationVM.instance;

  aboutToAppear(): void {
    this.vm.init()
  }

  private onColumnClicked(indexValue: string, snapShotComponentId: string, name: string): void {
    let param: Record<string, Object> = {};
    let clickedIndex = parseInt(indexValue);
    param.id = clickedIndex;
    param.indexValue = clickedIndex;
    param.snapShotId = snapShotComponentId;

    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(this.getUIContext(), snapShotComponentId, 9);
    if (longTakeTransitionParam) {
      param.longTakeTransitionParam = longTakeTransitionParam;
    }
    RouterModule.push(RouterMap.SEARCH, { 'keyword': name } as Record<string, string>);
  }

  build() {
    NavDestination() {
      Row() {
        Text('分类')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontFamily('HarmonyHeiTi')
          .height(56)
        Row() {
          if(this.vm.gridCount === 5) {
            Search({ placeholder: '输入关键词' })
              .width(400)
              .onClick(() => {
                RouterModule.push(RouterMap.SEARCH)
              })
          } else {
            Image($r('app.media.ic_title_search'))
              .width(40)
              .height(40)
              .onClick(() => {
                RouterModule.push(RouterMap.SEARCH)
              })
          }

          Image($r('app.media.ic_title_menu'))
            .width(40)
            .height(40)
            .margin({ left: 8 })
            .bindMenu(HeaderMenuBuilder())
            .visibility(Visibility.None)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ left: 16, right: 16 })
      .padding({top: 40, bottom: 10})
      .constraintSize({ maxWidth: '100%' })
      LinkCategory({
        recipeCategoryList: this.vm.recipeCategoryList,
        currentIndex: this.vm.currentIndex,
        gridCount: this.vm.gridCount,
        onRecipeClick: (listItem, index, name) => {
          this.onColumnClicked(listItem.id.toString(), `recipes_flow_${listItem.id}_${name}_${index}`, listItem.title)
        },
        changeCurrentIndex: (index: number) => {
          this.vm.changeCurrentIndex(index)
        },
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}