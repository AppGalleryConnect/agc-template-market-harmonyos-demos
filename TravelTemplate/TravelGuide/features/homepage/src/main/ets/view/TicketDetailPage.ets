import { TValueType, RouterMap } from 'common';
import { TicketReturnDetailListModel, TicketTypeModel } from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';
import { TicketOrderPageBuilder } from './TicketOrderPage';
import { DetailPageHeader } from '../components/DetailPageHeader';
import { TicketTripInfo } from '../components/TicketTripInfo';
import { TicketSeatSelector } from '../components/TicketSeatSelector';
import { TicketSeatItem } from '../common/model';

@Builder
export function TicketDetailPageBuilder(param: TValueType) {
  TicketDetailPage({
    pageParam: param
  })
}

@ComponentV2
export struct TicketDetailPage {
  @Param pageParam: TValueType = null
  @Local dataInfo: TicketReturnDetailListModel = this.pageParam as TicketReturnDetailListModel
  @Local listData: TicketTypeModel[] = [{ type: '经济舱', price: 891 }, { type: '商务舱', price: 2891 }]
  @Local listReturnData: TicketTypeModel[] = [{ type: '经济舱', price: 891 }, { type: '商务舱', price: 2891 }]
  @Local listOfficial: number[] = [1299, 1480]
  @Local clickIndex: number = 0
  @Local clickReturnIndex: number = 0
  @Local totalPrice: number = 0
  @Local goPrice: number = 0
  @Local backPrice: number = 0
  // 订单列表相关常量
  private readonly DISCOUNT_AMOUNT: number = 12

  aboutToAppear(): void {
    this.listData[0].price = Number(this.dataInfo.ticketGo.price)
    this.listReturnData[0].price = Number(this.dataInfo.ticketBack.price)
    this.goPrice = Number(this.dataInfo.ticketGo.price)
    this.backPrice = Number(this.dataInfo.ticketBack.price)
    if (this.dataInfo.ticketGo.type === 1) {
      this.totalPrice = Number(this.dataInfo.ticketGo.price) + Number(this.dataInfo.ticketBack.price)
    } else {
      this.totalPrice = Number(this.dataInfo.ticketGo.price)
    }
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  render() {
    Column() {
      Column() {
        // 使用通用头部组件
        DetailPageHeader({
          currentCity: this.dataInfo.ticketGo.currentCity,
          returnCity: this.dataInfo.ticketGo.returnCity
        })

        if (this.dataInfo.ticketGo.type === 0) {
          // 单程显示
          this.renderOneWay()
        } else {
          // 往返显示
          this.renderGoWay()
          this.renderBackWay()
        }
      }
      .padding(16)

      // 订单列表
      this.renderOrderList()
    }
  }

  @Builder
  renderOneWay() {
    Row() {
      Column() {
        Text(this.dataInfo.ticketGo.startDate)
          .fontSize(26)
          .margin({ bottom: 4 })
          .textAlign(TextAlign.Start)
        Text(this.dataInfo.ticketGo.startLocation)
          .fontSize(14)
          .textAlign(TextAlign.Start)
      }

      Column() {
        Image($r('app.media.ic_ticket'))
          .width(92)
      }
      .width(92)

      Column() {
        Text(this.dataInfo.ticketGo.endDate)
          .fontSize(26)
          .margin({ bottom: 4 })
          .textAlign(TextAlign.End)
        Text(this.dataInfo.ticketGo.endLocation)
          .fontSize(14)
          .textAlign(TextAlign.End)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 12 })

    Row() {
      Image($r('app.media.ic_ticket'))
        .width(10)
        .height(10)
      Text('海航｜海南航空HU760｜波音787｜飞2时30分｜起飞准点率87%')
        .opacity(0.3)
        .fontSize(10)
    }
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  renderOneWayList() {
    TicketSeatSelector({
      config: {
        label: '',
        seatList: this.listData,
        selectedIndex: this.clickIndex,
        itemWidth: '100%',
        showLabel: false,
        marginTop: 16,
        marginBottom: 12,
        onSeatSelected: (index: number, item: TicketSeatItem) => {
          this.clickIndex = index
          this.totalPrice = item.price
        }
      }
    })
  }

  @Builder
  renderGoWay() {
    TicketTripInfo({
      label: '去程',
      timeDate: this.dataInfo.ticketGo.timeDate,
      weekDate: this.dataInfo.ticketGo.weekDate,
      startDate: this.dataInfo.ticketGo.startDate,
      endDate: this.dataInfo.ticketGo.endDate,
      startLocation: this.dataInfo.ticketGo.startLocation,
      endLocation: this.dataInfo.ticketGo.endLocation
    })
      .margin({ bottom: 21 })
  }

  @Builder
  renderBackWay() {
    TicketTripInfo({
      label: '返程',
      timeDate: this.dataInfo.ticketBack.timeDate,
      weekDate: this.dataInfo.ticketBack.weekDate,
      startDate: this.dataInfo.ticketBack.startDate,
      endDate: this.dataInfo.ticketBack.endDate,
      startLocation: this.dataInfo.ticketBack.startLocation,
      endLocation: this.dataInfo.ticketBack.endLocation
    })
  }

  @Builder
  renderGoTab() {
    TicketSeatSelector({
      config: {
        label: '去程',
        seatList: this.listData,
        selectedIndex: this.clickIndex,
        itemWidth: '49%',
        showLabel: true,
        marginTop: 10,
        onSeatSelected: (index: number, item: TicketSeatItem) => {
          this.clickIndex = index
          this.goPrice = item.price
          this.dataInfo.ticketGo.cabinClass = item.type
          this.totalPrice = this.goPrice + this.backPrice
          this.dataInfo.ticketGo.price = item.price.toString()
        }
      }
    })
  }

  @Builder
  renderBackTab() {
    TicketSeatSelector({
      config: {
        label: '返程',
        seatList: this.listReturnData,
        selectedIndex: this.clickReturnIndex,
        itemWidth: '49%',
        showLabel: true,
        marginTop: 14,
        marginBottom: 14,
        onSeatSelected: (index: number, item: TicketSeatItem) => {
          this.clickReturnIndex = index
          this.backPrice = item.price
          this.totalPrice = this.goPrice + this.backPrice
          this.dataInfo.ticketBack.cabinClass = item.type
          this.dataInfo.ticketBack.price = item.price.toString()
        }
      }
    })
  }

  @Builder
  renderOrderList() {
    List({ space: 10 }) {
      if (this.dataInfo.ticketGo.type === 0) {
        // 单程显示
        this.renderOneWayList()
      } else {
        // 往返显示
        this.renderGoTab()
        this.renderBackTab()
      }
      ForEach(this.listOfficial, (item: number, index: number) => {
        ListItem() {
          Row() {
            // 左侧内容区域
            Column() {
              // 价格信息
              Row() {
                Text() {
                  Span('¥')
                    .fontSize(12)
                    .fontColor('#FF4A26')
                  Span(this.totalPrice.toString())
                    .fontSize(22)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FF4A26')
                  Span('已优惠¥' + this.DISCOUNT_AMOUNT)
                    .fontSize(10)
                    .fontColor('#FF4A26')
                }
              }
              .margin({ bottom: 6 })

              // 行李和退改信息
              Row() {
                Text('·无免费托运20KG')
                  .fontSize(12)
                  .fontColor('#C1771C')
                Text('·退改详情')
                  .fontSize(12)
                  .fontColor('#000000')
                  .opacity(0.4)
              }
              .margin({ bottom: 4 })

              // 优惠信息
              Row() {
                Text('·惠选经济舱3.3折｜电子行程单')
                  .fontSize(12)
                  .fontColor('#000000')
                  .opacity(0.4)
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            // 右侧订单按钮
            this.renderOrderButton()
          }
          .height(88)
          .alignItems(VerticalAlign.Center)
          .padding(12)
          .width('100%')
          .borderRadius(12)
          .backgroundColor('#fff')
        }
      }, (index: number) => index.toString())
    }
    .layoutWeight(1)
    .padding(16)
    .borderRadius({ topLeft: 16, topRight: 16 })
    .linearGradient({ angle: 180, colors: [['#FFFFFF', 0.0], ['#F2F2F2', 1.0], ['#F2F2F2', 1.0]] })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  renderOrderButton() {
    Row() {
      Text('订')
    }
    .borderRadius(24)
    .justifyContent(FlexAlign.Center)
    .width(54)
    .height(34)
    .backgroundColor('#FEE231')
    .onClick(() => {
      if (this.dataInfo.ticketGo.type === 0) {
        this.dataInfo.ticketGo.price = this.totalPrice.toString()
      }
      phoneRouterControl.jumpPage({
        pageName: RouterMap.TICKET_ORDER_PAGE,
        builder: wrapBuilder(TicketOrderPageBuilder),
        param: this.dataInfo
      })
    })
  }
}
