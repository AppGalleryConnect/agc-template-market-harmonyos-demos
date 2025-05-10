import { ClassificationVM } from '../viewModels/ClassificationVM';
import { CommonConstants, RouterMap, RouterModule } from 'commonlib';
import { RecipeBriefInfo, RecipeCategory } from 'network';

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

  @Builder
  titleBuilder() {
    Row() {
      Text('分类')
        .fontSize(24)
        .fontWeight(500)
        .padding({ left: 8 })
        .height(56)
        .margin({ left: 16 })
    }
    .width('100%')
  }

  // 分类列表
  @Builder
  leftListBuilder(typeName: string, index: number) {
    Row() {
      Text(typeName)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.vm.currentIndex === index ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
        .textAlign(TextAlign.Center)

    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.vm.currentIndex === index ? '#FF0000' : '#00000000')
    .width(CommonConstants.FULL_WIDTH)
    .height(40)
    .padding({
      left: 12,
      right: 4,
      top: 12,
      bottom: 12,
    })
    .margin({ right: 4 })
    .constraintSize({ maxWidth: CommonConstants.FULL_WIDTH })
    .borderRadius({ topRight: 12, bottomRight: 12 })
    .onClick(() => {
      this.vm.currentIndexChangeAction(index, true);
    })
  }

  // 右列表分类标题
  @Builder
  listTitleBuilder(title: string) {
    Row() {
      Text(title).fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
    }.width(CommonConstants.FULL_WIDTH).margin({ bottom: 12 })
  }

  build() {
    NavDestination() {
      this.titleBuilder()
      Column() {
        // 列表页
        Row() {
          List({ space: 8, scroller: this.vm.titleItemScroller }) {
            ForEach(this.vm.recipeCategoryList, (item: RecipeCategory, index: number) => {
              ListItem() {
                this.leftListBuilder(item.name, index,
                )
              }
            }, (item: RecipeCategory, index: number) => item.name + index)
          }
          .width(92)
          .height(CommonConstants.FULL_HEIGHT)
          .backgroundColor('#F1F3F5')
          .listDirection(Axis.Vertical) // 排列方向
          .scrollBar(BarState.Off)
          .contentStartOffset(12)
          .contentEndOffset(12)

          List({ space: 12, scroller: this.vm.scroller }) {
            ForEach(this.vm.recipeCategoryList, (item: RecipeCategory) => {
              ListItemGroup({
                header: this.listTitleBuilder(item.name),
                space: 12,
              }) {
                ListItem() {
                  Grid() {
                    ForEach(item.recipeList, (listItem: RecipeBriefInfo) => {
                      GridItem() {
                        Column() {
                          Image($r(`app.media.${listItem.thumbnail}`)).width(76).height(76).borderRadius(8)
                          Text(listItem.title)
                            .fontSize(14)
                            .fontWeight(FontWeight.Medium)
                            .fontColor($r('sys.color.font_primary'))
                            .textAlign(TextAlign.Center)
                            .constraintSize({ maxWidth: 76 })
                            .maxLines(2)
                            .margin({ top: 4 })
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                        }
                      }.onClick(() => {
                        RouterModule.push({ url: RouterMap.DISHES, param: { id: listItem.id } })
                      })

                    }, (listItem: RecipeBriefInfo) => `${item.id}${listItem.id}`)
                  }
                  .rowsGap(8)
                  .columnsGap(8)
                  .columnsTemplate('1fr 1fr 1fr')

                }

              }
            }, (item: RecipeCategory) => item.id.toString())
          }
          .layoutWeight(1)
          .height(CommonConstants.FULL_HEIGHT)
          .margin({ left: 8, right: 16 })
          .scrollBar(BarState.Off)
          .sticky(StickyStyle.None)
          .contentStartOffset(12)
          .contentEndOffset(12)
          .onScrollIndex((start: number) => this.vm.currentIndexChangeAction(start, false))
        }.layoutWeight(1)

      }
      .width(CommonConstants.FULL_WIDTH)
      .layoutWeight(1)
      .constraintSize({ maxHeight: CommonConstants.FULL_HEIGHT })

    }.hideTitleBar(true)
  }
}