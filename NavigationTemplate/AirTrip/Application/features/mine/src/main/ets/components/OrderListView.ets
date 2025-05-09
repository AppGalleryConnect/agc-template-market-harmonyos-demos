import { CommonDataSource, Constants, DayFormat, OrderInfo, pasteText } from 'common';

@ComponentV2
export struct OrderListView {
  @Param orderList: OrderInfo[] = []
  @Event refreshList: () => void = () => {
  }
  @Event deleteOrderItem: (item: OrderInfo, index: number) => void = (item: OrderInfo, index: number) => {
  }
  @Event cancelOrderItem: (item: OrderInfo, index: number) => void = (item: OrderInfo, index: number) => {
  }
  @Event payOrder: (item: OrderInfo) => void = (item: OrderInfo) => {
  }
  @Local isRefreshing: boolean = false
  @Local ratio: number = 1
  @Local maxRefreshingHeight: number = 100.0
  private listDataSource = new CommonDataSource<OrderInfo>()
  @Local totalCount: number = -1
  private orderStatusLabel: string[] = [
    '已取消', '待支付', '待出行', '已出行', '退改票',
  ]
  private orderStatusTextColors = [
    $r('sys.color.ohos_id_color_text_tertiary'), $r('app.color.color_text_red'), $r('app.color.color_text_green'),
    $r('sys.color.ohos_id_color_text_tertiary'), $r('sys.color.ohos_id_color_text_tertiary'),
  ]

  @Monitor('orderList', 'orderList.length')
  onChangeOrderList() {
    this.listDataSource.setData(this.orderList)
    this.totalCount = this.listDataSource.totalCount()
    this.isRefreshing = false
  }

  // 获取飞行时长
  getFlyDuration(item: OrderInfo) {
    let start = new Date(item.takeoffTime).getTime()
    let end = new Date(item.landingTime).getTime()
    let diff = end - start
    const totalMinutes = Math.floor(diff / (1000 * 60));
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;
    return `${hours}h${minutes}min`;
  }

  // 判断是否是次日
  isNextDay(item: OrderInfo): boolean {
    const depDate = new Date(item.takeoffTime).toDateString();
    const arrDate = new Date(item.landingTime).toDateString();
    return depDate !== arrDate;
  }

  // 获取总金额
  getTotalCount(item: OrderInfo): string {
    let price = (JSON.parse(item.passengerList ?? '[]')).length *
      (item.includeTaxPrice + item.airportConstructionPrice + item.fuelPrice)
    return price + ''
  }

  build() {
    Column() {
      Refresh({ refreshing: $$this.isRefreshing, builder: this.customRefreshComponent }) {
        if (this.totalCount === 0) {
          Scroll() {
            this.emptyBuilder()
          }
          .width(Constants.FULL_PERCENT_WIDTH)
          .height(Constants.FULL_PERCENT_HEIGHT)
        } else {
          List({ space: 12 }) {
            // 用来占位，布局使用
            ListItem() {
            }

            LazyForEach(this.listDataSource, (item: OrderInfo, index: number) => {
              ListItem() {
                this.OrderItemView(item, index)
              }
            }, (item: OrderInfo) => JSON.stringify(item))
          }
          .width(Constants.FULL_PERCENT_WIDTH)
          .height(Constants.FULL_PERCENT_HEIGHT)
          .padding({ left: 16, right: 16 })
        }
      }
      .onRefreshing(() => {
        this.refreshList && this.refreshList()
      })
      .pullToRefresh(true)
      .pullDownRatio(this.ratio)
      .refreshOffset(64)
      .onOffsetChange((offset: number) => {
        // 越接近最大距离，下拉跟手系数越小
        this.ratio = 1 - Math.pow((offset / this.maxRefreshingHeight), 3)
      })
    }
  }

  @Builder
  customRefreshComponent() {
    Row() {
    }
    .height(32)
    .width(Constants.FULL_PERCENT_WIDTH)
  }

  @Builder
  emptyBuilder() {
    Column() {
      Column() {
        Image($r('app.media.ic_empty'))
          .width(100)
          .height(80)
        Text('您没有待出行的行程')
          .fontSize(12)
          .fontColor('#ff9d9b9b')
      }
    }
    .width('100%')
    .height('50%')
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  OrderItemView(item: OrderInfo, index: number) {
    Column({ space: 12 }) {
      Row() {
        Row({ space: 8 }) {
          Text('订单号').fontSize(12).fontWeight(FontWeight.Regular)
          Text(item.orderNo).fontSize(12).fontWeight(FontWeight.Regular)
          Image($r('app.media.ic_copy')).width(16).height(16)
            .onClick(() => {
              // 复制订单编号
              pasteText(item.orderNo)
            })
        }

        Text(this.orderStatusLabel[item.status])
          .fontSize(12).fontColor(this.orderStatusTextColors[item.status])
          .fontWeight(FontWeight.Regular)
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)

      Divider().strokeWidth(0.5).color($r('sys.color.ohos_id_color_button_divider'))

      Row() {
        Row({ space: 8 }) {
          Image($r('app.media.ic_air_logo')).width(24).height(24)
          Text(item.airlineName).fontSize(12).fontWeight(FontWeight.Medium)
          Text(item.flightNo).fontSize(8).fontWeight(FontWeight.Regular)
          Text(item.aircraftType).fontSize(8).fontWeight(FontWeight.Regular)

          Text('单程')
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.white'))
            .padding({
              left: 6,
              right: 6,
              top: 2,
              bottom: 2,
            })
            .backgroundColor('#466DFA')
            .borderRadius(8)
            .position({ right: 0 })
        }
        .width(Constants.FULL_PERCENT_WIDTH)
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Column({ space: 4 }) {
          Text(new DayFormat(item.takeoffTime).format('HH:mm'))
            .fontSize(16).fontWeight(FontWeight.Regular)
          Row() {
            Text(item.departureAirport)
              .fontSize(10)
              .fontWeight(FontWeight.Regular)
              .fontColor('#99000000')
              .maxLines(1)
              .constraintSize({ maxWidth: 70 })
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }

        Column({ space: 4 }) {
          Text(this.getFlyDuration(item))
            .fontSize(8)
            .fontColor('#466DFA')
            .fontWeight(FontWeight.Regular)
            .backgroundColor('#DAE2FE')
            .padding({
              left: 8,
              right: 8,
              top: 2,
              bottom: 2,
            })
            .borderRadius(8)
          Image($r('app.media.ic_flight_tip')).width(60).height(12)
        }

        Column({ space: 4 }) {
          Text() {
            if (this.isNextDay(item)) {
              Span('次日').fontSize(8).fontWeight(FontWeight.Regular)
            }
            Span(new DayFormat(item.landingTime).format('HH:mm'))
              .fontSize(16).fontWeight(FontWeight.Regular)
          }

          Row() {
            Text(item.destinationAirport)
              .fontSize(10)
              .fontWeight(FontWeight.Regular)
              .fontColor('#99000000')
              .maxLines(1)
              .constraintSize({ maxWidth: 70 })
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .justifyContent(FlexAlign.SpaceAround)

      Row({ space: 4 }) {
        Text('总额').fontSize(12).fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        Text() {
          Span(Constants.RMB)
          Span(this.getTotalCount(item))
        }
        .fontSize(14)
        .fontColor('#D94838')
        .fontWeight(FontWeight.Medium)
      }
      .width(Constants.FULL_PERCENT_WIDTH)

      Divider().strokeWidth(0.5).color($r('sys.color.ohos_id_color_button_divider'))

      Row({ space: 8 }) {
        if (item.status === 1) {
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Text('支付').fontColor($r('sys.color.white')).fontSize(14)
          }
          .padding({
            left: 24,
            right: 24,
            top: 4,
            bottom: 4,
          })
          .backgroundColor($r('app.color.color_btn_emphasize_bg'))
          .onClick(() => {
            this.payOrder && this.payOrder(item)
          })
        }
        if (item.status === 1 || item.status === 2) {
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Text('取消').fontColor($r('sys.color.ohos_id_color_text_tertiary')).fontSize(14)
          }
          .padding({
            left: 24,
            right: 24,
            top: 4,
            bottom: 4,
          })
          .backgroundColor($r('app.color.color_btn_gray_bg'))
          .onClick(() => {
            this.cancelOrderItem && this.cancelOrderItem(item, index)
          })
        }

        Button({ type: ButtonType.Capsule, stateEffect: true }) {
          Text('删除').fontColor($r('sys.color.ohos_id_color_text_tertiary')).fontSize(14)
        }
        .padding({
          left: 24,
          right: 24,
          top: 4,
          bottom: 4,
        })
        .backgroundColor($r('app.color.color_btn_gray_bg'))
        .onClick(() => {
          this.deleteOrderItem && this.deleteOrderItem(item, index)
        })

      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .justifyContent(FlexAlign.End)
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .padding(12)
    .backgroundColor($r('sys.color.white'))
    .borderRadius(16)
  }
}