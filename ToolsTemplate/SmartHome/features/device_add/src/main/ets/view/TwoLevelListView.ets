@ComponentV2
export struct TwoLevelListView {
  private navTitleScroller: Scroller = new Scroller();
  private goodsListScroller: Scroller = new Scroller();
  @Local currentLevel1Index: number = 0;
  @BuilderParam level1ItemBuilder: (level1Index: number) => void
  @BuilderParam level2ItemBuilder: (level1Index: number, level2Index: number) => void

  @Require @Param level2ItemNum: number[]

  level1Index: number[] = []
  itemNum: number[][] = []

  listSpace = 15

  getIndexArray(num: number): number[] {
    let array: number[] = []
    for (let i = 0; i < num; i++) {
      array.push(i)
    }
    return array
  }

  aboutToAppear(): void {
    for (let i = 0; i < this.level2ItemNum.length; i++) {
      this.itemNum.push(this.getIndexArray(this.level2ItemNum[i]))
    }
  }

  @Builder BuildLevel1List() {
    List({ space: this.listSpace, scroller: this.navTitleScroller }) {
      ForEach(this.itemNum, (item: number[], level1Index: number) => {
        ListItem() {
          this.level1ItemBuilder(level1Index)
        }
        .backgroundColor((this.currentLevel1Index === level1Index) ? '#F1F3F5' : Color.Transparent)
        .onClick(() => {
          this.currentLevel1Index = level1Index
          this.goodsListScroller.scrollToIndex(level1Index);
        })
      },(item:number[])=>{
        return JSON.stringify(item)
      })
    }
    .width(100)
  }

  @Local level2ListHeight: number = 0
  @Local level2LastListItemGroupHeight: number = 0

  @Builder BuildLevel2List() {
    List({ space: this.listSpace, scroller: this.goodsListScroller }) {
      ForEach(this.itemNum, (item: number[], level1Index: number) => {
        ListItemGroup({space: this.listSpace}) {
          this.level1ItemBuilder(level1Index)
          ForEach(item, (level2Item: number, level2Index: number) => {
            ListItem() {
              this.level2ItemBuilder(level1Index, level2Index)
            }
          }, (level2Item: number) => {
            return JSON.stringify(level2Item)
          })
        }
        .onAreaChange((oldValue: Area, newValue: Area) => {
          this.level2LastListItemGroupHeight = Number(newValue.height)
        })
      }, (item: number[]) => {
        return JSON.stringify(item)
      })
      ListItem() {
        Column() {
        }
        .height(this.level2ListHeight - this.level2LastListItemGroupHeight - this.listSpace)
        .width('100%')
      }
    }
    .onScrollIndex((index: number) => {
      this.currentLevel1Index = index
      this.navTitleScroller.scrollToIndex(index);
    })
    .height('100%')
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.level2ListHeight = Number(newValue.height)
    })
  }

  build() {
    Row() {
      this.BuildLevel1List()
      Divider()
        .vertical(true)
        .strokeWidth(1)
        .margin({right: 12, left: 6})
      this.BuildLevel2List()
    }
    .height('100%')
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}
