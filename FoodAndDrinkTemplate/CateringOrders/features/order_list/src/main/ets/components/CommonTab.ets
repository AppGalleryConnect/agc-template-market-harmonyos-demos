import { OrderCard } from './OrderCard';
import { Constants, GetMyOrderResp, getMyOrderUtil, OrderStateEnum, TabBarType } from 'common/Index';

@Component
export struct CommonTab {
  @Consume('currentIndex') @Watch('currentIndexChange') currentIndex: number
  @Consume('refreshData') @Watch('refreshOrderList') refreshData: boolean
  @State currentState: OrderStateEnum = OrderStateEnum.All;
  @State orderList: Array<GetMyOrderResp> = [];
  scroller: Scroller = new Scroller()
  @State pageNum: number = 0

  currentIndexChange() {
    if (this.currentIndex === 1) {
      this.getMyOrder()
    }
  }

  getMyOrder() {
    getMyOrderUtil(this.pageNum, this.currentState).then((resp: Array<GetMyOrderResp>) => {
      this.orderList = resp
    })
  }

  aboutToAppear(): void {
    this.getMyOrder()
  }

  @Builder
  tabBuilder(index: number, name: Resource) {
    Column() {
      Text(name)
        .fontColor(this.currentState === index ? $r('sys.color.multi_color_09') : $r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
      if (this.currentState === index) {
        Row()
          .width(42)
          .height(0)
          .borderWidth({ bottom: 2 })
          .borderColor($r('sys.color.multi_color_09'))
          .margin({ top: 4 })
      }
    }
    .width(Constants.FULL_SIZE)
    .height(50)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Builder
  tabOrderList() {
    List({ space: 12 }) {
      ForEach(this.orderList, (item: GetMyOrderResp) => {
        OrderCard({
          orderItem: item, getMyOrder: () => {
            this.getMyOrder()
          },
        })
      }, (item: GetMyOrderResp) => JSON.stringify(item))
    }
    .scrollBar(BarState.Off)
    .height(Constants.FULL_SIZE)
    .margin({ top: 12 })
    .constraintSize({ maxHeight: Constants.FULL_SIZE })
  }

  build() {
    Column() {
      Tabs({ index: this.currentState }) {
        TabContent() {
          this.tabOrderList()
        }.tabBar(this.tabBuilder(OrderStateEnum.All, $r('app.string.all')))

        TabContent() {
          this.tabOrderList()
        }.tabBar(this.tabBuilder(OrderStateEnum.noFinished, $r('app.string.not_complete')))

        TabContent() {
          this.tabOrderList()
        }.tabBar(this.tabBuilder(OrderStateEnum.finished, $r('app.string.completed')))

        TabContent() {
          this.tabOrderList()
        }.tabBar(this.tabBuilder(OrderStateEnum.AfterSales, $r('app.string.other')))
      }
      .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
        this.currentState = targetIndex
      })
      .width(Constants.FULL_SIZE)
      .barHeight(50)
      .layoutWeight(1)
      .onChange((index) => {
        this.currentState = index;
        this.getMyOrder()
      })
    }.justifyContent(FlexAlign.Start)
  }

  refreshOrderList() {
    if (this.refreshData && this.currentIndex === TabBarType.ORDER) {
      this.getMyOrder()
      this.refreshData = false
    }
  }
}