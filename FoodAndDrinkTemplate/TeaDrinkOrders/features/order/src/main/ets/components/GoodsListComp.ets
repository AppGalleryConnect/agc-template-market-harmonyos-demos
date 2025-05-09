import { Constants, DishesType, Good } from 'common/Index';
import { GoodInfoComp } from './GoodInfoComp';

@ComponentV2
export struct GoodsListComp {
  @Consumer('dishesList') dishesList: Array<DishesType> = []
  @Consumer('dishesListOri') dishesListOri: Array<DishesType> = []
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()
  @Local currentIndex: number = 0;
  @Local buyCarMoney: number = 0; //购物车金额
  // 当前搜索关键字
  @Local searchText: string = '';
  private titleItemScroller: Scroller = new Scroller();
  private scroller: Scroller = new Scroller();

  // 下标索引处理
  currentIndexChangeAction(index: number, isClassify: boolean): void {
    if (this.currentIndex !== index) {
      this.currentIndex = index;
      if (isClassify) {
        this.scroller.scrollToIndex(index);
      } else {
        this.titleItemScroller.scrollToIndex(index);
      }
    }
  }

  // 列表头部
  @Builder
  titleHeader(title: string, count: number) {
    Row() {
      Text() {
        Span(`${title}`)
          .fontSize(14)
          .fontWeight(500)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(20)
        Span(`（${count}）`)
          .fontSize(10)
          .lineHeight(10)
          .fontColor($r('sys.color.mask_tertiary'))
          .padding({ left: 4 })
      }
    }
    .height(20)
    .width(Constants.FULL_SIZE)
    .margin({
      bottom: 5,
      top: 8,
      left: 16,
      right: 16,
    })
  }

  build() {
    Column() {
      Row() {
        Search({ value: $$this.searchText, placeholder: $r('app.string.search_goods') })
          .textFont({ size: $r('sys.float.Body_L') })
          .width(Constants.FULL_SIZE)
          .placeholderFont({ size: $r('sys.float.Body_L') })
          .maxLength(20)
          .onChange((value: string) => {
            if (value) {
              this.dishesList = this.dishesList.map((item) => {
                item.good = item.good.filter(i => i.name?.includes(value))
                return item
              })
            } else {
              this.dishesList = JSON.parse(JSON.stringify(this.dishesListOri))
            }
          })
      }
      .height(40)
      .padding({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })
      .margin({ top: 10, bottom: 8 })

      // 列表页
      Row() {
        List({ scroller: this.titleItemScroller }) {
          ForEach(this.dishesList, (item: DishesType, index?: number) => {
            ListItem() {
              TitleItem({
                typeName: item.typeName,
                isSelected: this.currentIndex === index,
                onClickAction: () => {
                  if (index !== undefined) {
                    this.currentIndexChangeAction(index, true);
                  }
                },
              })
            }
          }, (item: string) => item + this.currentIndex)
          ListItem() {
            Column().width(Constants.FULL_SIZE).height(78)
          }
        }
        .width(80)
        .height(Constants.FULL_SIZE)
        .listDirection(Axis.Vertical) // 排列方向
        .backgroundColor(Color.White)
        .scrollBar(BarState.Off)
        .divider({ strokeWidth: 1 })

        List({ scroller: this.scroller }) {
          ForEach(this.dishesList, (item: DishesType) => {
            ListItemGroup({
              header: this.titleHeader(item.typeName, item.good.length),
              space: 10,
            }) {
              ForEach(item.good, (listItem: Good) => {
                ListItem() {
                  GoodInfoComp({ good: listItem })
                }
              }, (listItem: Good) => JSON.stringify(listItem))

            }
          }, (item: DishesType) => JSON.stringify(item))
          ListItem() {
            Column() {
              Divider().margin({ top: 12 })
              Text($r('app.string.list_bottom'))
                .fontSize(8)
                .fontWeight(300)
                .fontColor($r('sys.color.mask_tertiary'))
                .margin({ top: 8 })
            }.width(Constants.FULL_SIZE).height(106)
          }
        }
        .layoutWeight(1)
        .height(Constants.FULL_SIZE)
        .scrollBar(BarState.Off)
        .sticky(StickyStyle.None)
        .onScrollIndex((start: number) => this.currentIndexChangeAction(start, false))
      }.layoutWeight(1)

    }
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .constraintSize({ maxHeight: Constants.FULL_SIZE })

  }
}

// 标题
@ComponentV2
export struct TitleItem {
  @Param @Require typeName: string;
  @Param @Require isSelected: boolean;
  @Event onClickAction: () => void = () => {
  }

  build() {
    Row() {
      Text(this.typeName)
        .fontSize(12)
        .fontColor(this.isSelected ? $r('app.color.mainColor') : '#99000000')
        .textAlign(TextAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.isSelected ? '#EBEFE2' : '#0D979797')
    .width(Constants.FULL_SIZE)
    .height(48)
    .padding({ left: 10, right: 10 })
    .border({ width: { right: this.isSelected ? 0.5 : 0 }, color: $r('app.color.mainColor') })
    .onClick(this.onClickAction)
  }
}

