import { RouterMap, TValueType } from 'common';
import { PlaneReturnDetailListModel, PlaneTypeModel } from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';
import { PlaneOrderPageBuilder } from './PlaneOrderPage';
import { DetailPageHeader } from '../components/DetailPageHeader';
import { SeatTypeSelector, SeatTypeSelectorRow } from '../components/SeatTypeSelector';
import { OrderListItem } from '../components/OrderListItem';
import { PlaneTripInfo } from '../components/PlaneTripInfo';
import { SeatTypeItem } from '../common/model';

@Builder
export function PlaneDetailPageBuilder(param: TValueType) {
  PlaneDetailPage({
    pageParam: param
  })
}

@ComponentV2
export struct PlaneDetailPage {
  @Param pageParam: TValueType = null
  @Local dataInfo: PlaneReturnDetailListModel = this.pageParam as PlaneReturnDetailListModel
  @Local listData: PlaneTypeModel[] = []
  @Local listReturnData: PlaneTypeModel[] = []
  @Local clickIndex: number = 0
  @Local clickReturnIndex: number = 0
  @Local totalPrice: number = 0
  @Local goPrice: number = 0
  @Local backPrice: number = 0
  @Local priceList: number[] = [0, 1]
  // 常量
  private readonly DISCOUNT_AMOUNT: number = 12
  private readonly DEFAULT_SEAT_TYPES: PlaneTypeModel[] = [
    { type: '二等座', price: 499, tickets: 4 },
    { type: '一等座', price: 891, tickets: 400 },
    { type: '商务座', price: 1491, tickets: 40 },
    { type: '无座', price: 499, tickets: 4 }
  ]

  aboutToAppear(): void {
    this.initData()
  }

  // 初始化数据
  initData(): void {
    // 初始化座位列表
    this.listData = this.DEFAULT_SEAT_TYPES.map((item: PlaneTypeModel): PlaneTypeModel => {
      return {
        type: item.type,
        price: item.price,
        tickets: item.tickets
      }
    })
    this.listReturnData = this.DEFAULT_SEAT_TYPES.map((item: PlaneTypeModel): PlaneTypeModel => {
      return {
        type: item.type,
        price: item.price,
        tickets: item.tickets
      }
    })

    // 设置价格
    this.listData[0].price = Number(this.dataInfo.planeGo.price)
    this.listReturnData[0].price = Number(this.dataInfo.planeBack.price)

    // 初始化价格
    this.goPrice = Number(this.dataInfo.planeGo.price)
    this.backPrice = Number(this.dataInfo.planeBack.price)
    this.totalPrice = this.dataInfo.planeGo.type === 1
      ? this.goPrice + this.backPrice
      : this.goPrice
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
          currentCity: this.dataInfo.planeGo.currentCity,
          returnCity: this.dataInfo.planeGo.returnCity
        })

        if (this.dataInfo.planeGo.type === 0) {
          // 单程显示
          this.renderOneWay()
        } else {
          // 往返显示
          this.renderRoundTrip()
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
        Text(this.dataInfo.planeGo.startDate)
          .fontSize(26)
          .margin({ bottom: 4 })
          .textAlign(TextAlign.Start)
        Text(this.dataInfo.planeGo.startLocation)
          .fontSize(14)
          .textAlign(TextAlign.Start)
      }

      Column() {
        Text(this.dataInfo.planeGo.duration)
          .fontSize(10)
          .fontColor('#000')
          .opacity(0.5)
        Row() {
          Image($r('app.media.ic_train_right'))
            .width(47)
            .height(5)
        }

        Text(this.dataInfo.planeGo.trainNumber)
          .fontSize(10)
          .fontColor('#000')
          .opacity(0.5)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Text(this.dataInfo.planeGo.endDate)
          .fontSize(26)
          .margin({ bottom: 4 })
          .textAlign(TextAlign.End)
        Text(this.dataInfo.planeGo.endLocation)
          .fontSize(14)
          .textAlign(TextAlign.End)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 12 })

    // 使用通用座位选择器
    SeatTypeSelector({
      seatList: this.convertToSeatTypeItems(this.listData),
      selectedIndex: this.clickIndex,
      showTickets: true,
      onSeatSelected: (index: number, item: SeatTypeItem) => {
        this.handleOneWaySeatSelected(index, item)
      }
    })
  }

  @Builder
  renderRoundTrip() {
    // 去程信息
    PlaneTripInfo({
      label: '去程',
      timeDate: this.dataInfo.planeGo.timeDate,
      weekDate: this.dataInfo.planeGo.weekDate,
      duration: this.dataInfo.planeGo.duration,
      trainNumber: this.dataInfo.planeGo.trainNumber,
      startDate: this.dataInfo.planeGo.startDate,
      endDate: this.dataInfo.planeGo.endDate,
      startLocation: this.dataInfo.planeGo.startLocation,
      endLocation: this.dataInfo.planeGo.endLocation
    })
      .margin({ bottom: 21 })

    // 返程信息
    PlaneTripInfo({
      label: '返程',
      timeDate: this.dataInfo.planeBack.timeDate,
      weekDate: this.dataInfo.planeBack.weekDate,
      duration: this.dataInfo.planeBack.duration,
      trainNumber: this.dataInfo.planeBack.trainNumber,
      startDate: this.dataInfo.planeBack.startDate,
      endDate: this.dataInfo.planeBack.endDate,
      startLocation: this.dataInfo.planeBack.startLocation,
      endLocation: this.dataInfo.planeBack.endLocation
    })
      .margin({ bottom: 20 })
  }

  // 处理去程座位选择
  handleGoSeatSelected(index: number, item: SeatTypeItem): void {
    this.clickIndex = index
    this.goPrice = item.price
    this.totalPrice = this.goPrice + this.backPrice
    this.dataInfo.planeGo.seatClass = item.type
    this.dataInfo.planeGo.price = item.price.toString()
  }

  // 处理返程座位选择
  handleBackSeatSelected(index: number, item: SeatTypeItem): void {
    this.clickReturnIndex = index
    this.backPrice = item.price
    this.totalPrice = this.goPrice + this.backPrice
    this.dataInfo.planeBack.seatClass = item.type
    this.dataInfo.planeBack.price = item.price.toString()
  }

  // 处理单程座位选择
  handleOneWaySeatSelected(index: number, item: SeatTypeItem): void {
    this.clickIndex = index
    this.totalPrice = item.price
    this.dataInfo.planeGo.seatClass = item.type
  }

  @Builder
  renderOrderList() {
    List({ space: 10 }) {
      if (this.dataInfo.planeGo.type !== 0) {
        // 去程座位选择
        SeatTypeSelectorRow({
          label: '去程',
          seatList: this.convertToSeatTypeItems(this.listData),
          selectedIndex: this.clickIndex,
          onSeatSelected: (index: number, item: SeatTypeItem) => {
            this.handleGoSeatSelected(index, item)
          }
        })

        // 返程座位选择
        SeatTypeSelectorRow({
          label: '返程',
          seatList: this.convertToSeatTypeItems(this.listReturnData),
          selectedIndex: this.clickReturnIndex,
          onSeatSelected: (index: number, item: SeatTypeItem) => {
            this.handleBackSeatSelected(index, item)
          }
        })
      }

      ForEach(this.priceList, (item: number, index: number) => {
        ListItem() {
          OrderListItem({
            config: {
              totalPrice: index === 0 ? this.totalPrice - this.DISCOUNT_AMOUNT : this.totalPrice,
              discountPrice: index === 0 ? this.DISCOUNT_AMOUNT : undefined,
              description: ['·全天随时可出票 ·需登录12306账号'],
              orderPageName: RouterMap.PLANE_ORDER_PAGE,
              orderPageBuilder: wrapBuilder(PlaneOrderPageBuilder),
              orderData: this.dataInfo,
              onOrderClick: () => {
                this.handleOrderClick(index)
              }
            },
            index: index
          })
        }
      }, (item: number) => item?.toString())
    }
    .layoutWeight(1)
    .padding(16)
    .borderRadius({ topLeft: 16, topRight: 16 })
    .linearGradient({ angle: 180, colors: [['#FFFFFF', 0.0], ['#F2F2F2', 1.0], ['#F2F2F2', 1.0]] })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  // 处理订单点击
  handleOrderClick(index: number): void {
    if (this.dataInfo.planeGo.type === 0) {
      this.dataInfo.planeGo.price =
        index === 0 ? (this.totalPrice - this.DISCOUNT_AMOUNT).toString() : this.totalPrice.toString()
    }
  }

  // 转换PlaneTypeModel到SeatTypeItem
  convertToSeatTypeItems(list: PlaneTypeModel[]): SeatTypeItem[] {
    return list.map((item: PlaneTypeModel): SeatTypeItem => {
      return {
        type: item.type,
        price: item.price,
        tickets: item.tickets
      }
    })
  }
}