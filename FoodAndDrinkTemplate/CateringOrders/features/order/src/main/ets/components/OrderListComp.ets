import { Constants, DishesType, Good } from 'common/Index';
import { MustGoodsController } from '../models/MustGoodsController';
import { GoodInfoComp } from './GoodInfoComp';

@Component
export struct OrderListComp {
  @Consume('dishesList') @Watch('dishesListChange') dishesList: Array<DishesType>
  @Consume('pageStack') pageStack: NavPathStack
  @Consume('mustGoodsCtrl') mustGoodsCtrl: MustGoodsController
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28
  @State currentIndex: number = 0;
  @State buyCarMoney: number = 0; //购物车金额
  @State index: number = 0
  private titleItemScroller: Scroller = new Scroller();
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    if (this.mustGoodsCtrl) {
      this.mustGoodsCtrl.goMustGoods = this.goMustGoods
    }
    this.dishesListChange()
  }

  dishesListChange() {
    this.index = this.dishesList.findIndex(item => item.good?.some(i => i.isMust === Constants.GOODS_MUST))
  }

  goMustGoods = () => {
    if (this.mustGoodsCtrl.isNeedMustGoods && this.index >= 0) {
      this.scroller.scrollToIndex(this.index);
    }
  }

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
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Span(`（${count}）`)
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_secondary'))
          .padding({ left: 4 })
      }
    }
    .height(20)
    .width(Constants.FULL_SIZE)
    .margin({
      bottom: 8,
      top: 8,
      left: 16,
      right: 16,
    })
  }

  build() {
    Column() {
      // 列表页
      Row() {
        List({ scroller: this.titleItemScroller }) {
          ForEach(this.dishesList, (item: DishesType, index: number) => {
            ListItem() {
              TitleItem({
                typeName: item.typeName,
                hasIcon: item.id === Constants.GOOD_TYPE_HOT,
                isSelected: this.currentIndex === index,
                onClickAction: () => {
                  if (index !== undefined) {
                    this.currentIndexChangeAction(index, true);
                  }
                },
              })
            }
          }, (item: DishesType, index: number) => item.typeName + this.currentIndex)
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
                  GoodInfoComp({ item: listItem })
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
                .fontColor($r('sys.color.font_primary'))
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

    }.width(Constants.FULL_SIZE).height(Constants.FULL_SIZE).constraintSize({ maxHeight: Constants.FULL_SIZE })
  }
}

// 标题
@Component
export struct TitleItem {
  @Prop typeName?: string;
  @Prop hasIcon: boolean = false
  @Prop isSelected: boolean = false;
  onClickAction = (): void => {
  }

  build() {
    Row() {
      if (this.hasIcon) {
        Image($r('app.media.ic_hot')).width(16)
      }
      Text(this.typeName)
        .fontSize($r('sys.float.Body_S'))
        .fontColor(this.isSelected ? $r('sys.color.multi_color_09') : $r('sys.color.font_secondary'))
        .textAlign(TextAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.isSelected ? '#0FED6F21' : '#0D979797')
    .width(Constants.FULL_SIZE)
    .height(48)
    .padding({ left: 10, right: 10 })
    .border({ width: { right: this.isSelected ? 0.5 : 0 }, color: $r('sys.color.multi_color_09') })
    .onClick(this.onClickAction)
  }
}

