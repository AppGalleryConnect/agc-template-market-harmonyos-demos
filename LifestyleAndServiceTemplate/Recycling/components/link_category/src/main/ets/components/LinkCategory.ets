import { RecipeBriefInfo, RecipeCategory } from '../types/Index';

@ComponentV2
export struct LinkCategory {
  @Param themeColor: ResourceColor = 'rgba(255, 75, 75, 1)'
  @Param recipeCategoryList: RecipeCategory[] = []
  @Param currentIndex: number = 0
  @Param selectedItems: Map<string, string> = new Map()
  titleItemScroller: Scroller = new Scroller();
  scroller: Scroller = new Scroller();
  @Event onRecipeClick: (recipeDetail: RecipeBriefInfo, categoryName: string) => void = () => {
  }
  @Event changeCurrentIndex: (currentIndex: number) => void = () => {
  }

  // 下标索引处理
  currentIndexChangeAction(index: number, isClassify: boolean): void {
    if (this.currentIndex !== index) {
      this.changeCurrentIndex(index);
      if (isClassify) {
        this.scroller.scrollToIndex(index);
      } else {
        this.titleItemScroller.scrollToIndex(index);
      }
    }
  }

  // 分类列表
  @Builder
  leftListBuilder(typeName: string, index: number) {
    Row() {
      Text(typeName)
        .fontSize(14)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.currentIndex === index ? this.themeColor : 'rgba(0, 0, 0, 0.6)')
        .backgroundColor(this.currentIndex === index ? 'rgba(255, 255, 255, 1)' : 'rgba(0, 0, 0, 0)')
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .borderRadius(8)
        .layoutWeight(1)
        .height(56)
        .margin({ left: 2, right: 2, top: 2 })

    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(56)
    .onClick(() => {
      this.currentIndexChangeAction(index, true);
    })
  }

  // 右列表分类标题
  @Builder
  listTitleBuilder(title: string) {
    Row() {
      Text(title)
        .height(56)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('rgba(0, 0, 0, 1)')
        .textAlign(TextAlign.Center)
    }.width('100%')
  }

  build() {
    Column() {
      // 列表页
      Row() {
        List({ scroller: this.titleItemScroller }) {
          ForEach(this.recipeCategoryList, (item: RecipeCategory, index: number) => {
            ListItem() {
              this.leftListBuilder(item.name, index)
            }
          }, (item: RecipeCategory, index: number) => item.name + index)
        }
        .width(80)
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .borderRadius({ topRight: 8 })
        .listDirection(Axis.Vertical) // 排列方向
        .scrollBar(BarState.Off)
        .contentEndOffset(12)
        .margin({ top: 16 })
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

        List({ space: 12, scroller: this.scroller }) {
          ForEach(this.recipeCategoryList, (item: RecipeCategory) => {
            ListItemGroup({
              header: this.listTitleBuilder(item.name),
              space: 12,
            }) {
              ListItem() {
                Grid() {
                  ForEach(item.recipeList, (listItem: RecipeBriefInfo) => {
                    GridItem() {
                      Column() {
                        ForEach(listItem.title.split('|'), (titleItem: string, index: number) => {
                          if (index === 0) {
                            Text(titleItem)
                              .fontSize(14)
                              .fontColor(this.isKeyValueRelative(item.name, listItem.title) ?
                                'rgba(255, 75, 75, 1)' : 'rgba(0, 0, 0, 1)')
                              .textAlign(TextAlign.Center)
                          } else {
                            Text(titleItem)
                              .fontSize(10)
                              .fontColor(this.isKeyValueRelative(item.name, listItem.title) ?
                                'rgba(255, 75, 75, 1)' : 'rgba(0, 0, 0, 0.4)')
                              .textAlign(TextAlign.Center)
                          }
                        }, (item: string, idx: number) => JSON.stringify(item) + idx)
                      }
                      .width('100%')
                      .height(44)
                      .backgroundColor(this.isKeyValueRelative(item.name, listItem.title) ?
                        'rgba(255, 75, 75, 0.1)' :
                        'rgba(0, 0, 0, 0.05)')
                      .borderRadius(8)
                      .justifyContent(FlexAlign.Center)
                      .alignItems(HorizontalAlign.Center)
                      .padding({ left: 8, right: 8, top: 4, bottom: 4})
                    }.onClick(() => {
                      this.onRecipeClick(listItem, item.name)
                    })

                  }, (listItem: RecipeBriefInfo) => `${item.id}${listItem.id}`)
                }
                .rowsGap(8)
                .columnsGap(8)
                .columnsTemplate('1fr 1fr')
              }

            }
          }, (item: RecipeCategory) => item.id.toString())
        }
        .layoutWeight(1)
        .height('100%')
        .margin({ left: 12, right: 12 })
        .scrollBar(BarState.Off)
        .sticky(StickyStyle.None)
        .contentStartOffset(12)
        .contentEndOffset(12)
        .onScrollIndex((start: number) => this.currentIndexChangeAction(start, false))
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }.layoutWeight(1)

    }
    .width('100%')
    .layoutWeight(1)
    .constraintSize({ maxHeight: '100%' })
  }

  // 判断是否key-value相对
  isKeyValueRelative(key: string, value: string): boolean {
    return this.selectedItems.has(key) && this.selectedItems.get(key) === value;
  }
}
