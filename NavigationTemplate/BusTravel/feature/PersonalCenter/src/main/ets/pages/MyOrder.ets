import { RouteEntryVM } from 'common'
import { getDataFromJSON } from 'common';
import { OrderSet } from '../model/ExpendSet'
import { PageHeader } from '../components/PageHeader';


@Builder
export function MyOrderBuilder() {
  MyOrder()
}

@Component
export struct MyOrder {
  vm: RouteEntryVM = RouteEntryVM.instance;
  @State orderSetItems: Array<OrderSet> = []

  aboutToAppear(): void {
    this.initDataSource()
    console.log('============' + JSON.stringify(this.orderSetItems))
  }

  initDataSource() {
    this.orderSetItems = getDataFromJSON<OrderSet>('PersonalCenter_MyOrder.json', this);
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          this.buildMyOrder()

        }
        .height('100%')
        .width('100%')
        .backgroundImageSize(ImageSize.Auto)
        .backgroundColor('#F1F3F5')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .scrollBarWidth('0vp')
    }
    .hideTitleBar(false)
    .title('我的订单')
  }

  @Builder
  buildMyOrder() {
    ForEach(this.orderSetItems, (orderSetItem: OrderSet) => {
      buildSettingItemView(orderSetItem);
    },(orderSetItem:OrderSet)=>orderSetItem.id)
  }
}

@Builder
function buildSettingItemView(item: OrderSet) {

  Column(){
    Row(){
      Image($r('app.media.icon_time'))
        .height(16)
        .width(16)
        .margin({right:8})
      Text('乘车时间：')
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
      Text(item.time)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
    }
    .margin({bottom:8})
    Row(){
      Image($r('app.media.icon_station_point'))
        .height(16)
        .width(16)
        .margin({right:8})
      Text('起点-终点：')
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
      Text(){
        Span(item.startStop)
        Span('-')
        Span('文鼎广场')
      }
      .fontSize(14)
      .fontWeight(FontWeight.Regular)
    }
    .margin({bottom:8})
    Row(){
      Image($r('app.media.icon_way'))
        .height(16)
        .width(16)
        .margin({right:8})
      Text(){
        Span('途径')
        Span(item.way)
        Span('站')
      }
      .fontSize(14)
      .fontWeight(FontWeight.Regular)
    }
    .margin({bottom:8})
    Row(){
      Image($r('app.media.icon_money'))
        .height(16)
        .width(16)
        .margin({right:8})
      Text('金额：')
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
      Text(){
        Span('￥')
        Span(item.money)
      }
      .fontSize(14)
      .fontWeight(FontWeight.Regular)
    }
  }
  .alignItems(HorizontalAlign.Start)
  .borderRadius(16)
  .width('90%')
  .padding(12)
  .backgroundColor($r('sys.color.white'))
  .margin({ top: 12 })
}
