import { CalendarPickerUtil, DialogType, SwiperDirection, TypePicker } from '@hw-agconnect/ui-calendar-picker';
import { BreakpointModel, RouterMap, TValueType } from 'common';
import { phoneRouterControl } from 'oh_router';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import {
  ChooseStatus,
  HotelDateModel,
  MockTicketPriceService,
  MockTicketReturnPriceService,
  MockTrainTicketPriceService,
  MockTrainTicketReturnPriceService,
  PlaneDetailListModel,
  PlanePageVM,
  PlaneReturnDetailListModel,
  TicketDetailListModel,
  TicketPriceListModel,
  TicketPriceModel,
  TicketReturnDetailListModel,
  TrainTicketPriceListModel,
  TrainTicketPriceModel,
  TripType
} from 'common_travel_guide';
import { TicketDetailPageBuilder } from './TicketDetailPage';
import { PlaneDetailPageBuilder } from './PlaneDetailPage';
import { CarDetailPageBuilder } from './CarDetailPage';
import { CitySelectPageBuilder } from './CitySelectPage';
import { City } from 'city_select';
import { GridRowColSetting } from 'common/src/main/ets/constant/GridRowColSetting';
import { TicketParam } from './PlaneTicketPage';

@Builder
export function TicketPricesPageBuilder(param: TValueType) {
  TicketPricesPage({
    pageParam: param
  })
}

@ComponentV2
export struct TicketPricesPage {
  @Param pageParam: TValueType = null
  @Local dataInfo: PlanePageVM = new PlanePageVM()
  vmType: PlanePageVM = new PlanePageVM()
  vm: TicketPriceModel[] = MockTicketPriceService.travelerResult
  vmReturn: TicketPriceModel[] = MockTicketReturnPriceService.travelerResult
  vmTrain: TrainTicketPriceModel[] = MockTrainTicketPriceService.travelerResult
  vmTrainReturn: TrainTicketPriceModel[] = MockTrainTicketReturnPriceService.travelerResult
  vmCar: TrainTicketPriceModel[] = MockTrainTicketPriceService.travelerResult
  @Local list: TicketPriceModel = new TicketPriceModel()
  @Local listTrain: TrainTicketPriceModel = new TrainTicketPriceModel()
  @Local listTrainReturn: TrainTicketPriceModel = new TrainTicketPriceModel()
  @Local listReturn: TicketPriceModel = new TicketPriceModel()
  @Local listCar: TrainTicketPriceModel = new TrainTicketPriceModel()
  @Local outboundIndex: number = 0
  @Local returnIndex: number = 0
  @Local outboundListIndex: number | null = null
  @Local returnListIndex: number | null = null
  @Local today: Date = new Date()
  @Local hotelDateModel: HotelDateModel = HotelDateModel.instance
  @Local selectDate: string = ''
  @Local selectReturnDate: string = ''
  @Local changeType: boolean = false
  @Local returnPrice: number = 0
  @Local backPrice: number = 0
  @Local goPrice: number = 0
  @Local backDateTime: number = 0
  @Local backDate: string = ''
  @Local goDateTime: number = 0
  @Local goDate: string = ''
  @Local backWeek: string = ''
  @Local goWeek: string = ''
  @Local goStatus: boolean = false
  @Local backStatus: boolean = false
  @Local planeListPriceData: PlaneReturnDetailListModel = new PlaneReturnDetailListModel()
  @Local ticketListPriceData: TicketReturnDetailListModel = new TicketReturnDetailListModel()
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // 是否折叠屏展开状态
  @Local collapseExpandState: boolean = GridRowColSetting.checkColumnCountModel();

  @Monitor('breakPointModel.currentBreakpoint')
  breakPointChange() {
    this.collapseExpandState = GridRowColSetting.checkColumnCountModel()
  }

  private listScroller: ListScroller = new ListScroller()
  private listReturnScroller: ListScroller = new ListScroller()
  // 单程及去程无切换
  @Event paramChangeCallback: (data: HotelDateModel) => void = () => {
    this.selectDate = `${this.hotelDateModel.checkInDate.getMonth() + 1}-${this.hotelDateModel.checkInDate.getDate()}`
    if (this.dataInfo.currentCity === '上海市') {
      this.getPriceList(this.selectDate)
    } else {
      this.goPriceGoList(this.selectDate)
    }

  };
  // 选择返程日期
  @Event paramChangeReturnCallback: (data: HotelDateModel) => void = () => {
    this.selectReturnDate =
      `${this.hotelDateModel.checkOutDate.getMonth() + 1}-${this.hotelDateModel.checkOutDate.getDate()}`
    if (this.dataInfo.currentCity === '上海市') {
      this.backTogoList(this.selectReturnDate)
    } else {
      this.backPriceList(this.selectReturnDate)
    }
  };
  // 选择往返日期
  @Event paramGoAndReturnCallback: (data: HotelDateModel) => void = () => {
    this.selectDate = `${this.hotelDateModel.checkInDate.getMonth() + 1}-${this.hotelDateModel.checkInDate.getDate()}`
    this.selectReturnDate =
      `${this.hotelDateModel.checkOutDate.getMonth() + 1}-${this.hotelDateModel.checkOutDate.getDate()}`

    if (this.dataInfo.currentCity === '上海市') {
      this.initDataReturn(this.selectReturnDate, this.selectDate)
    } else {
      this.initDataBack(this.selectDate, this.selectReturnDate)
    }

  };

  getWeekday(dateString: string) {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const date = new Date(dateString);
    const weekday = date.getDay();
    return weekdays[weekday];
  }

  getISODate(dateStr: string): Date {
    const parts = dateStr.split('-')
    const month = parseInt(parts[0])
    const day = parseInt(parts[1])
    const year = new Date().getFullYear()
    return new Date(Date.UTC(year, month - 1, day))
  }

  scrollerToOutbound() {
    setTimeout(() => {
      this.listScroller.scrollToIndex(this.outboundIndex)
    }, 100)
  }

  scrollerToReturnTrip() {
    setTimeout(() => {
      this.listReturnScroller.scrollToIndex(this.returnIndex)
    }, 100)
  }

  aboutToAppear(): void {
    this.dataInfo = (this.pageParam as TicketParam)?.vm
    this.hotelDateModel = (this.pageParam as TicketParam)?.hotelDateModel
    this.vmType.chooseStatus = this.dataInfo.chooseStatus
    this.vmType.returnSatus = this.dataInfo.returnSatus
    this.backWeek = this.dataInfo.backWeek
    this.goWeek = this.dataInfo.goWeek
    this.goDate = `${this.hotelDateModel.checkInDate.getMonth() + 1}-${this.hotelDateModel.checkInDate.getDate()}`
    this.backDate = `${this.hotelDateModel.checkOutDate.getMonth() + 1}-${this.hotelDateModel.checkOutDate.getDate()}`
    if (this.dataInfo.currentCity === '上海市') {
      this.initDataReturn(this.backDate, this.goDate);
    } else {
      this.initDataBack(this.goDate, this.backDate)
    }
  }

  // 初始化切换往返程数据
  initDataReturn(endTime: string, startTime: string) {
    this.backTogoList(endTime)
    this.getPriceList(startTime)
  }

  // 判断是否是北京和上海地区
  isCityCorrect() {
    if ((this.dataInfo.currentCity === '北京市' && this.dataInfo.returnCity === '上海市') ||
      (this.dataInfo.currentCity === '上海市' && this.dataInfo.returnCity === '北京市')) {
      return true
    } else {
      return false
    }
  }

  // 去程赋值给返程
  backTogoList(endTime: string) {
    this.vm.forEach((item: TicketPriceModel, index: number) => {
      if (this.isCityCorrect()) {
        if (endTime === item.dateCode) {
          this.returnIndex = index
          this.scrollerToReturnTrip()
          this.listReturn = item
          this.backDateTime = item.dateNumber ?? new Date(new Date().toDateString()).getTime()
        }
      } else {
        this.listReturn = new TicketPriceModel()
      }
    })
    this.vmTrain.forEach((item: TrainTicketPriceModel, index: number) => {
      if (this.isCityCorrect()) {
        if (endTime === item.dateCode) {
          this.returnIndex = index
          this.scrollerToReturnTrip()
          this.listTrainReturn = item
          this.backDateTime = item.dateNumber ?? new Date(new Date().toDateString()).getTime()
        }
      } else {
        this.listTrainReturn = new TrainTicketPriceModel()
      }
    })
    this.vmTrain.forEach((item: TrainTicketPriceModel, index: number) => {
      if (this.isCityCorrect()) {
        if (endTime === item.dateCode) {
          this.outboundIndex = index
          this.scrollerToOutbound()
          this.listCar = item
          this.goDateTime = item.dateNumber ?? new Date(new Date().toDateString()).getTime()
        }
      } else {
        this.listCar = new TrainTicketPriceModel()
      }
    })
  }

  // 去程赋值给去程
  goPriceGoList(endTime: string) {
    this.vm.forEach((item: TicketPriceModel, index: number) => {
      if (this.isCityCorrect()) {
        if (endTime === item.dateCode) {
          this.outboundIndex = index
          this.scrollerToOutbound()
          this.list = item
        }
      } else {
        this.list = new TicketPriceModel()
      }
    })
    this.vmTrain.forEach((item: TrainTicketPriceModel, index: number) => {
      if (this.isCityCorrect()) {
        if (endTime === item.dateCode) {
          this.outboundIndex = index
          this.scrollerToOutbound()
          this.listTrain = item
        }
      } else {
        this.listTrain = new TrainTicketPriceModel()
      }
    })
    this.vmCar.forEach((item: TrainTicketPriceModel, index: number) => {
      if (this.isCityCorrect()) {
        if (endTime === item.dateCode) {
          this.outboundIndex = index
          this.scrollerToOutbound()
          this.listCar = item
        }
      } else {
        this.listCar = new TrainTicketPriceModel()
      }
    })
  }

  // 返程赋值给去程
  getPriceList(date: string) {
    this.vmReturn.forEach((item: TicketPriceModel, index: number) => {
      if (this.isCityCorrect()) {
        if (date === item.dateCode) {
          this.outboundIndex = index
          this.scrollerToOutbound()
          this.list = item
          this.goDateTime = item.dateNumber ?? new Date(new Date().toDateString()).getTime()
        }
      } else {
        this.list = new TicketPriceModel()
      }
    })
    this.vmTrainReturn.forEach((item: TrainTicketPriceModel, index: number) => {
      if (this.isCityCorrect()) {
        if (date === item.dateCode) {
          this.outboundIndex = index
          this.scrollerToOutbound()
          this.listTrain = item
          this.goDateTime = item.dateNumber ?? new Date(new Date().toDateString()).getTime()
        }
      } else {
        this.listTrain = new TrainTicketPriceModel()
      }
    })
    this.vmTrainReturn.forEach((item: TrainTicketPriceModel, index: number) => {
      if (this.isCityCorrect()) {
        if (date === item.dateCode) {
          this.outboundIndex = index
          this.scrollerToOutbound()
          this.listCar = item
          this.goDateTime = item.dateNumber ?? new Date(new Date().toDateString()).getTime()
        }
      } else {
        this.listCar = new TrainTicketPriceModel()
      }
    })
  }

  // 返程赋值给返程
  backPriceList(endTime: string) {
    this.vmReturn.forEach((item: TicketPriceModel, index: number) => {
      if (this.isCityCorrect()) {
        if (endTime === item.dateCode) {
          this.returnIndex = index
          this.scrollerToReturnTrip()
          this.listReturn = item
          this.backDateTime = item.dateNumber ?? new Date(new Date().toDateString()).getTime()
        }
      } else {
        this.listReturn = new TicketPriceModel()
      }
    })
    this.vmTrainReturn.forEach((item: TrainTicketPriceModel, index: number) => {
      if (this.isCityCorrect()) {
        if (endTime === item.dateCode) {
          this.listTrainReturn = item
          this.returnIndex = index
          this.scrollerToReturnTrip()
          this.backDateTime = item.dateNumber ?? new Date(new Date().toDateString()).getTime()
        }
      } else {
        this.listTrainReturn = new TrainTicketPriceModel()
      }
    })
  }

  // 初始化无切换往返数据
  initDataBack(startTime: string, endTime: string) {
    this.goPriceGoList(startTime)
    this.backPriceList(endTime)
  }

  // 选择往返时间
  public handleConfirm(date: Date | Date[]) {
    let dates: Date[] = date as Date[];

    const weekArr = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

    // 去程日期
    this.goDate = `${dates[0].getMonth() + 1}-${dates[0].getDate()}`;
    this.goWeek = weekArr[dates[0].getDay()];
    // 返程日期
    this.backDate = `${dates[1].getMonth() + 1}-${dates[1].getDate()}`;
    this.backWeek = weekArr[dates[1].getDay()];

    this.hotelDateModel.checkInDate = dates[0];
    this.hotelDateModel.checkOutDate = dates[1];
    this.paramGoAndReturnCallback?.(this.hotelDateModel)
  }

  // 单程及去程日期
  public handleConfirmData(date: Date | Date[]) {
    let dates: Date = date as Date;
    if (this.vmType.returnSatus === 1 && new Date(dates).getTime() > this.hotelDateModel.checkOutDate.getTime()) {
      promptAction.showToast({ message: '去程的到达时间不得晚于返程的出发时间' });
      return
    }
    const month = dates.getMonth() + 1;
    const day = dates.getDate();
    this.goDate = `${month}-${day}`;

    // 获取星期
    const weekDay = dates.getDay();
    const weekChinese = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][weekDay];
    this.goWeek = weekChinese
    this.hotelDateModel.checkInDate = dates;
    this.paramChangeCallback?.(this.hotelDateModel)
    this.listScroller.scrollToIndex(this.outboundIndex)
  }

  // 返程日期
  public handleConfirmDataReturn(date: Date | Date[]) {
    let dates: Date = date as Date;
    if (new Date(dates).getTime() < this.hotelDateModel.checkInDate.getTime()) {
      promptAction.showToast({ message: '返程出发时间不得早于去程到达时间' });
      return
    }
    const month = dates.getMonth() + 1;
    const day = dates.getDate();
    this.backDate = `${month}-${day}`;

    // 获取星期
    const weekDay = dates.getDay();
    const weekChinese = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][weekDay];
    this.backWeek = weekChinese

    this.hotelDateModel.checkOutDate = dates;
    this.paramChangeReturnCallback?.(this.hotelDateModel)
    this.listReturnScroller.scrollToIndex(this.returnIndex)
  }

  addTicketDetailData(item: TicketPriceListModel) {
    let data: TicketDetailListModel = new TicketDetailListModel()
    data.currentCity = this.dataInfo.currentCity
    data.returnCity = this.dataInfo.returnCity
    data.startDate = item.startDate
    data.endDate = item.endDate
    data.startLocation = item.startLocation
    data.endLocation = item.endLocation
    data.price = item.price
    data.boeing = item.boeing
    data.aviation = item.aviation
    data.chooseStatus = 0
    data.peopleList = this.dataInfo.selectTravelerId
    return data
  }

  addPlaneDetailData(item: TrainTicketPriceListModel) {
    let data: PlaneDetailListModel = new PlaneDetailListModel()
    data.currentCity = this.dataInfo.currentCity
    data.returnCity = this.dataInfo.returnCity
    data.duration = item.duration
    data.trainNumber = item.trainNumber
    data.firstClass = item.firstClass
    data.secondClass = item.secondClass
    data.businessClass = item.businessClass
    data.noSeat = item.noSeat
    data.startDate = item.startDate
    data.endDate = item.endDate
    data.startLocation = item.startLocation
    data.endLocation = item.endLocation
    data.price = item.price
    data.chooseStatus = 1
    data.peopleList = this.dataInfo.selectTravelerId
    return data
  }

  startTimeSafeCheck(startDate: string, startTime: string) {
    if (new Date(this.dataInfo.startYear + '-' + startDate + ' ' + startTime).getTime() <
    new Date().getTime()) {
      promptAction.showToast({ message: '出发时间不得早于当前时间' });
      return false
    }
    return true
  }

  goEndTimeSafeCheck(backStartDate: string, goEndTime: string) {
    if (this.dataInfo.returnSatus === 1 && backStartDate?.length > 0 && goEndTime?.length > 0 &&
      new Date(this.dataInfo.endYear + '-' + this.backDate + ' ' + backStartDate).getTime() <
      new Date(this.dataInfo.startYear + '-' + this.goDate + ' ' + goEndTime).getTime()) {
      promptAction.showToast({ message: '去程的到达时间不得晚于返程的出发时间' });
      return false
    }
    return true
  }

  backStartTimeSafeCheck(backStartDate: string, goEndTime: string) {
    if (this.dataInfo.returnSatus === 1 && backStartDate?.length > 0 && goEndTime?.length > 0 &&
      new Date(this.dataInfo.endYear + '-' + this.backDate + ' ' + backStartDate).getTime() <
      new Date(this.dataInfo.startYear + '-' + this.goDate + ' ' + goEndTime).getTime()) {
      promptAction.showToast({ message: '返程出发时间不得早于去程到达时间' });
      return false
    }
    return true
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
    .backgroundColor('#fff')

  }

  @Builder
  render() {
    Column() {
      Column() {
        Row() {
          Image($r('app.media.leftReturn'))
            .width(40)
            .height(40)
            .onClick(() => {
              phoneRouterControl.popPage()
              return true
            })
          Row() {
            Text(this.dataInfo.currentCity)
              .fontSize(16)
              .fontColor('#000')
              .margin({ right: 8 })
            Image($r('app.media.ic_right'))
              .width(20)
            Text(this.dataInfo.returnCity)
              .fontSize(16)
              .fontColor('#000')
              .margin({ left: 8, right: 4 })
            Image($r('app.media.ic_bottom'))
              .width(20)
              .height(20)
              .onClick(() => {
                this.changeType = !this.changeType
              })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .margin({ bottom: 16 })
      }
      .backgroundColor('#fff')
      .padding({ left: 16, right: 16, top: 44 })

      this.topPop()
      Column()
        .position({ x: 0, y: 100 })
        .zIndex(990)
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .visibility(this.changeType === true ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.changeType = false
        })
      this.ticketList()
      this.bottomButton()
    }
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .backgroundColor('#F1F3F5')
  }

  @Builder
  bottomButton() {
    Row() {
      Row() {
        Text('往返总价 ')
          .fontSize(12)
          .fontColor('#000')
          .opacity(0.5)
          .margin({ bottom: 4 })
        Text() {
          Span('¥')
            .fontSize(16)
          Span(this.returnPrice.toString())
            .fontSize(20)
        }
        .fontColor('#FF4A26')
      }
      .alignItems(VerticalAlign.Bottom)

      Row() {
        Text('下一步')
          .fontSize(14)
      }
      .borderRadius(24)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .enabled(this.backStatus === true && this.goStatus === true ? true : false)
      .backgroundColor(this.backStatus === true && this.goStatus === true ? '#FFE431' : '#f3f3f3')
      .width(96)
      .height(40)
      .onClick(() => {
        if (this.dataInfo.chooseStatus === 1) {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.PLANE_DETAIL_PAGE,
            builder: wrapBuilder(PlaneDetailPageBuilder),
            param: this.planeListPriceData
          })
        }
        if (this.dataInfo.chooseStatus === 0) {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.TICKET_DETAIL_PAGE,
            builder: wrapBuilder(TicketDetailPageBuilder),
            param: this.ticketListPriceData
          })
        }
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .justifyContent(FlexAlign.SpaceBetween)
    .visibility(this.dataInfo.returnSatus === 0 ? Visibility.None : Visibility.Visible)
  }

  //头部弹窗
  @Builder
  topPop() {
    Column() {
      Row() {
        Row() {
          Text('单程')
        }
        .onClick(() => {
          this.vmType.returnSatus = TripType.OneWay
        })
        .width(152)
        .height(26)
        .justifyContent(FlexAlign.Center)
        .borderRadius(6)
        .backgroundColor(this.vmType.returnSatus === TripType.OneWay ? '#ffffff' : 'rgba(0, 0, 0, 0)')

        Row() {
          Text('往返')
        }
        .onClick(() => {
          this.vmType.returnSatus = TripType.Return
        })
        .justifyContent(FlexAlign.Center)
        .width(152)
        .height(26)
        .borderRadius(6)
        .backgroundColor(this.vmType.returnSatus === TripType.Return ? '#ffffff' : 'rgba(0, 0, 0, 0)')
      }
      .margin({ top: 12, bottom: 26 })
      .width(308)
      .height(30)
      .borderRadius(6)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#EDF0F2')
      .visibility(this.dataInfo.chooseStatus === ChooseStatus.Bus ? Visibility.None : Visibility.Visible)

      Row() {
        Row() {
          Text(this.dataInfo.currentCity)
        }
        .width(137)
        .justifyContent(FlexAlign.Start)
        .onClick(() => {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.CITY_SELECT_PAGE,
            builder: wrapBuilder(CitySelectPageBuilder),
            param: this.vmType.currentCity,
            onPop: (popInfo: PopInfo) => {
              let result = popInfo?.result as City;
              if (result && result.name) {
                this.dataInfo.currentCity = result.name as string
                this.dataInfo.currentCity1 = result.name as string
              }
            }
          })
        })

        Row() {
          Image($r('app.media.ic_switch'))
            .width(30)
            .height(30)
        }
        .onClick(() => {
          this.vmType.currentReturn = !this.vmType.currentReturn
          if (this.vmType.currentReturn === true) {
            this.dataInfo.currentCity = this.dataInfo.returnCity1
            this.dataInfo.returnCity = this.dataInfo.currentCity1
            this.vmType.currentCity = this.vmType.returnCity1
            this.vmType.returnCity = this.vmType.currentCity1
          } else {
            this.dataInfo.currentCity = this.dataInfo.currentCity1
            this.vmType.currentCity = this.vmType.currentCity1
            this.vmType.returnCity = this.vmType.returnCity1
            this.dataInfo.returnCity = this.dataInfo.returnCity1
          }

        })

        Row() {
          Text(this.dataInfo.returnCity)
        }
        .width(137)
        .justifyContent(FlexAlign.End)
        .onClick(() => {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.CITY_SELECT_PAGE,
            builder: wrapBuilder(CitySelectPageBuilder),
            param: this.vmType.returnCity,
            onPop: (popInfo: PopInfo) => {
              let result = popInfo?.result as City;
              if (result && result.name) {
                this.dataInfo.returnCity = result.name as string
                this.dataInfo.returnCity1 = result.name as string
              }
            }
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ bottom: 28, top: this.dataInfo.chooseStatus === ChooseStatus.Bus ? 26 : 0 })

      if (this.vmType.returnSatus === TripType.Return && this.vmType.chooseStatus !== ChooseStatus.Bus) {
        this.roundTripDateSelector()
      } else {
        this.singleTripDateSelector()
      }

      Row() {
        Text('搜索')
          .fontSize(16)
          .fontColor('#333')
      }
      .margin({ top: 24 })
      .onClick(() => {
        this.changeType = false
        this.dataInfo.returnSatus = this.vmType.returnSatus
        this.listScroller.scrollToIndex(this.outboundIndex)
        if (this.vmType.returnSatus === TripType.Return) {
          this.paramGoAndReturnCallback?.(this.hotelDateModel)
          this.listReturnScroller.scrollToIndex(this.returnIndex)
        } else {
          this.paramChangeCallback?.(this.hotelDateModel)
        }
      })
      .width('100%')
      .backgroundColor('#FEE641')
      .borderRadius(24)
      .height(43)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .position({ x: 0, y: 100 })
    .zIndex(999)
    .backgroundColor('#ffffff')
    .padding({ left: 12, right: 12, bottom: 12 })
    .borderRadius({ bottomLeft: 16, bottomRight: 16 })
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .visibility(this.changeType === true ? Visibility.Visible : Visibility.None)
  }

  //车票列表
  @Builder
  ticketList() {
    Column() {
      // 机票单程数据列表
      if (this.dataInfo.chooseStatus === 0 && this.dataInfo.returnSatus === 0) {
        Row() {
          this.content()
          Column() {
            this.calendarIconBuilder()
          }
          .backgroundColor(Color.White)
          .padding({
            left: 18,
            right: 18,
            bottom: 12
          })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')

        this.contentList()
      }
      // 机票往返数据列表
      if (this.dataInfo.chooseStatus === 0 && this.dataInfo.returnSatus === 1) {
        Row() {
          Column() {
            Row() {
              Text('去程')
                .fontSize(14)
                .fontColor('#000')
                .textAlign(TextAlign.Start)
            }
            .width('100%')
            .height(28)
            .margin({ top: 8 })
            .padding({ left: 10 })
            .alignItems(VerticalAlign.Center)
            .backgroundColor('#FFF8CC')
            .borderRadius({ topRight: 12, topLeft: 12 })

            Row() {
              this.content()
              Column() {
                this.calendarIconBuilder()
              }
              .backgroundColor(Color.White)
              .padding({
                left: 10,
                right: 10,
                top: 12,
                bottom: 12
              })
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            .backgroundColor(Color.White)

            this.contentListOutbound()
          }
          .width('50%')
          .margin({ right: 2 })

          Column() {
            Row() {
              Text('返程')
                .fontSize(14)
                .fontColor('#000')
                .textAlign(TextAlign.Start)
            }
            .width('100%')
            .height(28)
            .margin({ top: 8 })
            .padding({ left: 10 })
            .alignItems(VerticalAlign.Center)
            .backgroundColor('#FFF8CC')
            .borderRadius({ topRight: 12, topLeft: 12 })

            Row() {
              this.contentReturn()
              Column() {
                this.calendarIconBuilderReturn()
              }
              .backgroundColor(Color.White)
              .padding({
                left: 10,
                right: 10,
                top: 12,
                bottom: 12
              })
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            .backgroundColor(Color.White)

            this.contentListReturn()
          }.width('50%')
        }
        .alignItems(VerticalAlign.Top)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      // 火车票单程数据列表
      if (this.dataInfo.chooseStatus === 1 && this.dataInfo.returnSatus === 0) {
        Row() {
          this.contentTrain()
          Column() {
            this.calendarIconBuilder()
          }
          .backgroundColor(Color.White)
          .padding({
            left: 18,
            right: 18,
            top: 12,
            bottom: 12
          })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')

        this.contentTrainList()
      }
      // 火车票往返数据列表
      if (this.dataInfo.chooseStatus === 1 && this.dataInfo.returnSatus === 1) {
        Row() {
          Column() {
            Row() {
              Text('去程')
                .fontSize(14)
                .fontColor('#000')
                .textAlign(TextAlign.Start)
            }
            .width('100%')
            .height(28)
            .margin({ top: 8 })
            .padding({ left: 10 })
            .borderRadius({ topRight: 12, topLeft: 12 })
            .alignItems(VerticalAlign.Center)
            .backgroundColor('#FFF8CC')

            Row() {
              this.contentTrain()
              Column() {
                this.calendarIconBuilder()
              }
              .backgroundColor(Color.White)
              .padding({
                left: 10,
                right: 10,
                top: 12,
                bottom: 12
              })
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            .backgroundColor(Color.White)

            this.contentListTrainOutbound(this.listTrain.dataArray)
          }
          .width('50%')
          .margin({ right: 2 })

          Column() {
            Row() {
              Text('返程')
                .fontSize(14)
                .fontColor('#000')
                .textAlign(TextAlign.Start)
            }
            .width('100%')
            .height(28)
            .margin({ top: 8 })
            .padding({ left: 10 })
            .alignItems(VerticalAlign.Center)
            .backgroundColor('#FFF8CC')
            .borderRadius({ topRight: 12, topLeft: 12 })

            Row() {
              this.contentTrainReturn()
              Column() {
                this.calendarIconBuilderReturn()
              }
              .backgroundColor(Color.White)
              .padding({
                left: 10,
                right: 10,
                top: 12,
                bottom: 12
              })
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            .backgroundColor(Color.White)

            this.contentListTrainReturn(this.listTrainReturn.dataArray)
          }.width('50%')
        }
        .alignItems(VerticalAlign.Top)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      // 汽车票单程数据列表
      if (this.dataInfo.chooseStatus === 2 && this.dataInfo.returnSatus === 0) {
        Row() {
          this.contentCar()
          Column() {
            this.calendarIconBuilder()
          }
          .backgroundColor(Color.White)
          .padding({
            left: 18,
            right: 18,
            top: 12,
            bottom: 12
          })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')

        this.contentCarList()
      }
    }
    .layoutWeight(1)
  }

  //飞机票单程top日期栏
  @Builder
  content() {
    List({ scroller: this.listScroller }) {
      ForEach(this.vmType.currentReturn === true ? this.vmReturn : this.vm, (item: TicketPriceModel, index: number) => {
        ListItem() {
          Column() {
            this.dateCellBuilder(item.date, item.dateCode, item.price)
          }
          .borderRadius(12)
          .padding({ top: 4, bottom: 4 })
          .backgroundColor(this.outboundIndex === index ? '#FEE231' : '#fff')
          .alignItems(HorizontalAlign.Center)
          .width(this.dataInfo.returnSatus === 1 ? 49 : 57)
          .onClick(() => {
            this.goStatus = false;
            if (this.dataInfo.returnSatus === 1 && this.backDateTime > 0 && item.dateNumber &&
              item.dateNumber > this.backDateTime) {
              promptAction.showToast({ message: '去程日期不得晚于返程日期' });
              return
            }
            this.outboundIndex = index
            this.goDate = item.dateCode
            this.goWeek = item.date
            this.goDateTime = item.dateNumber ?? 0
            this.hotelDateModel.checkInDate = this.getISODate(this.goDate)
            if (this.vmType.currentReturn === false && index > 2) {
              this.listScroller.scrollToIndex(index - 2)
            }
            this.goPrice = 0;
            this.returnPrice = 0;
            this.outboundListIndex = -1;
          })
        }
        .width(57)
        .height(51)
      }, (item: TicketPriceModel) => item.id?.toString())
    }
    .backgroundColor('#fff')
    .padding({ left: 20, right: 4 })
    .height(67)
    .layoutWeight(1)
    .alignListItem(ListItemAlign.Center)
    .listDirection(Axis.Horizontal)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }

  //飞机票单程数据列表
  @Builder
  contentList() {
    List({ space: 12 }) {
      ForEach(this.list.dataArray, (item: TicketPriceListModel, index: number) => {
        ListItem() {
          Row() {
            Image($r('app.media.ic_aviation_01'))
              .width(24)
              .height(24)
              .margin({ right: 12 })
            Column() {
              Row() {
                Text(item.startDate)
                  .fontSize(18)
                  .fontWeight(500)
                Image($r('app.media.ic_topLine'))
                  .width(47)
                  .height(5)
                Text(item.endDate)
                  .fontSize(18)
                  .fontWeight(500)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)

              Row() {
                Text(item.startLocation)
                  .fontSize(12)
                  .fontColor('#000')
                  .opacity(0.7)
                Text(item.endLocation)
                  .fontSize(12)
                  .fontColor('#000')
                  .opacity(0.7)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ top: 2, bottom: 6 })

              Row() {
                Text(item.aviation)
                  .fontSize(10)
                  .fontColor('#000')
                  .opacity(0.5)
                  .textAlign(TextAlign.Start)
                Text(' | ' + item.boeing)
                  .fontSize(10)
                  .fontColor('#000')
                  .opacity(0.5)
                  .textAlign(TextAlign.Start)
              }
              .width('100%')
            }
            .layoutWeight(1)
            .margin({ right: 12 })

            Column() {
              Text('¥' + item.price)
                .fontColor('#FF4A26')
                .fontSize(18)
                .margin({ bottom: 4 })
              Text(item.dark)
                .fontColor('#000')
                .opacity(0.6)
                .fontSize(12)
            }
          }
          .onClick(() => {
            if (!this.startTimeSafeCheck(this.goDate, item.startDate)) {
              return
            }
            if (!this.goEndTimeSafeCheck(this.ticketListPriceData.ticketBack.startDate, item.endDate)) {
              return
            }
            let data = this.addTicketDetailData(item)
            data.type = 0
            data.weekDate = this.goWeek
            data.timeDate = this.goDate
            this.ticketListPriceData.ticketGo = data
            phoneRouterControl.jumpPage({
              pageName: RouterMap.TICKET_DETAIL_PAGE,
              builder: wrapBuilder(TicketDetailPageBuilder),
              param: this.ticketListPriceData
            })
          })
          .padding(12)
          .width('100%')
          .borderRadius(12)
          .alignItems(VerticalAlign.Top)
          .justifyContent(FlexAlign.SpaceAround)
          .backgroundColor('#fff')
        }
      },
        (item: TicketPriceListModel, index: number) => `${item.startLocation}_${index}_${item.id}`
      )
    }
    .margin({ top: 10, bottom: 10 })
    .layoutWeight(1)
    .backgroundColor('#F2F2F2')
    .padding({ left: 16, right: 16 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }

  //飞机票返程top日期栏
  @Builder
  contentReturn() {
    List({ space: 10, scroller: this.listReturnScroller }) {
      ForEach(this.vmType.currentReturn === true ? this.vm : this.vmReturn, (item: TicketPriceModel, index: number) => {
        ListItem() {
          Column() {
            this.dateCellBuilder(item.date, item.dateCode, item.price)
          }
          .borderRadius(12)
          .padding({ top: 4, bottom: 4 })
          .backgroundColor(this.returnIndex === index ? '#FEE231' : '#fff')
          .alignItems(HorizontalAlign.Center)
          .width(this.dataInfo.returnSatus === 1 ? 49 : 57)
          .onClick(() => {
            this.backStatus = false;
            if (this.dataInfo.returnSatus === 1 && this.goDateTime > 0 && item.dateNumber &&
              item.dateNumber < this.goDateTime) {
              promptAction.showToast({ message: '返程日期不得早于去程日期' });
              return
            }
            this.returnIndex = index
            this.backDate = item.dateCode
            this.backWeek = item.date
            this.backDateTime = item.dateNumber ?? 0
            this.hotelDateModel.checkOutDate = this.getISODate(this.backDate)
            this.returnListIndex = 0;
            this.backPrice = 0;
            this.returnPrice = 0;
            this.returnListIndex = null;
          })
        }
        .width(57)
        .height(51)
      }, (item: TicketPriceModel) => item.id?.toString())
    }
    .backgroundColor('#fff')
    .padding({ left: 4, right: 4 })
    .height(67)
    .layoutWeight(1)
    .alignListItem(ListItemAlign.Center)
    .listDirection(Axis.Horizontal)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }

  //飞机票返程数据列表
  @Builder
  contentListReturn() {
    List() {
      ForEach(this.listReturn.dataArray, (item: TicketPriceListModel, index: number) => {
        ListItem() {
          Row() {
            this.planeDetail(item)
          }
          .onClick(() => {
            if (!this.backStartTimeSafeCheck(item.startDate, this.ticketListPriceData.ticketGo.endDate)) {
              return
            }
            let data = this.addTicketDetailData(item)
            data.type = 1
            data.weekDate = this.backWeek
            data.timeDate = this.backDate
            this.backPrice = Number(item.price)
            this.returnPrice = this.backPrice + this.goPrice
            this.returnListIndex = index
            this.ticketListPriceData.ticketBack = data
            this.backStatus = true
          })
          .padding({ bottom: 10 })
          .width('100%')
          .backgroundColor(this.returnListIndex === index ? '#FFFBE4' : '#fff')
          .justifyContent(FlexAlign.SpaceAround)
        }
      },
        (item: TicketPriceListModel, index: number) => `${item.startLocation}_${index}_${item.id}`)
    }
    .layoutWeight(1)
    .backgroundColor('#fff')
    .padding({ left: 8, right: 8 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }

  // 飞机票列表详情
  @Builder
  planeDetail(item: TicketPriceListModel) {
    Column() {
      Row() {
        Text(item.startDate)
          .fontSize(14)
        Image($r('app.media.ic_topLine'))
          .width(47)
          .height(5)
        Text(item.endDate)
          .fontSize(14)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text(item.startLocation)
          .fontSize(10)
          .fontColor('#000')
          .opacity(0.7)
        Text(item.endLocation)
          .fontSize(10)
          .fontColor('#000')
          .opacity(0.7)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 2, bottom: 10 })

      Row() {
        if (this.collapseExpandState) {
          Row({ space: 4 }) {
            Row() {
              Image($r('app.media.ic_aviation_01'))
                .width(10)
                .height(10)
              Text(item.aviation)
                .fontSize(10)
                .fontColor('#000')
                .opacity(0.6)
                .textAlign(TextAlign.Start)
            }

            Row() {
              Text(item.boeing)
                .fontSize(10)
                .fontColor('#000')
                .opacity(0.6)
                .textAlign(TextAlign.Start)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
          }.layoutWeight(1)
        } else {
          Column({ space: 4 }) {
            Row() {
              Image($r('app.media.ic_aviation_01'))
                .width(10)
                .height(10)
              Text(item.aviation)
                .fontSize(10)
                .fontColor('#000')
                .opacity(0.6)
                .textAlign(TextAlign.Start)
            }

            Row() {
              Text(item.boeing)
                .fontSize(10)
                .fontColor('#000')
                .opacity(0.6)
                .textAlign(TextAlign.Start)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
          }
          .width(84)
        }

        Column() {
          Text('¥' + item.price)
            .fontColor('#FF4A26')
            .fontSize(16)
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Bottom)
      .width('100%')
    }
    .layoutWeight(1)
    .height(90)
    .padding({ top: 12, left: 12, right: 12 })
  }

  //飞机票去程数据列表
  @Builder
  contentListOutbound() {
    List() {
      ForEach(this.list.dataArray, (item: TicketPriceListModel, index: number) => {
        ListItem() {
          Row() {
            this.planeDetail(item)
          }
          .onClick(() => {
            if (!this.startTimeSafeCheck(this.goDate, item.startDate)) {
              return
            }
            if (!this.goEndTimeSafeCheck(this.ticketListPriceData.ticketBack.startDate, item.endDate)) {
              return
            }
            let data = this.addTicketDetailData(item)
            data.type = 1
            data.weekDate = this.goWeek
            data.timeDate = this.goDate
            this.goPrice = Number(item.price)
            this.returnPrice = this.backPrice + this.goPrice
            this.outboundListIndex = index
            this.ticketListPriceData.ticketGo = data
            this.goStatus = true
          })
          .padding({ bottom: 10 })
          .width('100%')
          .backgroundColor(this.outboundListIndex === index ? '#FFFBE4' : '#fff')
          .justifyContent(FlexAlign.SpaceAround)
        }
      },
        (item: TicketPriceListModel, index: number) => `${item.startLocation}_${index}_${item.id}`)
    }
    .layoutWeight(1)
    .backgroundColor('#fff')
    .padding({ left: 8, right: 8 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }

  //火车票票单程top日期栏
  @Builder
  contentTrain() {
    List({ space: 8, scroller: this.listScroller }) {
      ForEach(this.vmType.currentReturn === true ? this.vmTrainReturn : this.vmTrain,
        (item: TrainTicketPriceModel, index: number) => {
          ListItem() {
            Column() {
              this.dateCellBuilder(item.date, item.dateCode, item.price)
            }
            .borderRadius(12)
            .padding({ top: 4, bottom: 4 })
            .backgroundColor(this.outboundIndex === index ? '#FEE231' : '#fff')
            .alignItems(HorizontalAlign.Center)
            .width(this.dataInfo.returnSatus === 1 ? 49 : 57)
            .onClick(() => {
              this.goStatus = false;
              if (this.dataInfo.returnSatus === 1 && this.backDateTime > 0 && item.dateNumber &&
                item.dateNumber > this.backDateTime) {
                promptAction.showToast({ message: '去程日期不得晚于返程日期' });
                return
              }
              this.outboundIndex = index
              this.goDate = item.dateCode
              this.goWeek = item.date
              this.hotelDateModel.checkInDate = this.getISODate(this.goDate)
              this.goDateTime = item.dateNumber ?? 0
              if (this.vmType.currentReturn === false && index > 2) {
                this.listScroller.scrollToIndex(index - 2)
              }
              this.goPrice = 0;
              this.returnPrice = 0;
              this.outboundListIndex = -1;
            })
          }
          .width(57)
          .height(51)
        }, (item: TrainTicketPriceModel) => item.id?.toString())
    }
    .backgroundColor('#fff')
    .padding({ left: 20, right: 4 })
    .height(67)
    .layoutWeight(1)
    .alignListItem(ListItemAlign.Center)
    .listDirection(Axis.Horizontal)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }

  // 火车票单程始发地及车次
  @Builder
  oneWay(item: TrainTicketPriceListModel) {
    Row() {
      Column() {
        Row() {
          Text(item.startDate)
            .fontSize(18)
            .fontWeight(500)
          Column() {
            Text(item.duration)
              .fontSize(12)
              .opacity(0.7)
            Row() {
              Image($r('app.media.ic_train_right'))
                .width(47)
                .height(5)
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Text(item.endDate)
            .fontSize(18)
            .fontWeight(500)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text(item.startLocation)
            .fontSize(12)
            .fontColor('#000')
            .opacity(0.7)
          Text(item.trainNumber)
            .fontSize(12)
            .fontColor('#000')
            .opacity(0.7)
          Text(item.endLocation)
            .fontSize(12)
            .fontColor('#000')
            .opacity(0.7)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .margin({ right: 20 })
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Text('¥' + item.price)
          .fontColor('#FF4A26')
          .fontSize(18)
      }
    }
    .margin({ bottom: 10 })
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  // 火车票往返始发地及车次
  @Builder
  roundTrip(item: TrainTicketPriceListModel) {
    Row() {
      Column() {
        Row() {
          Text(item.startDate)
            .fontSize(14)
            .fontWeight(500)
          Column() {
            Text(item.duration)
              .fontSize(10)
              .fontColor('#000')
              .opacity(0.5)
            Row() {
              Image($r('app.media.ic_train_right'))
                .width(47)
                .height(5)
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Text(item.endDate)
            .fontSize(14)
            .fontWeight(500)
            .textAlign(TextAlign.End)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text(item.startLocation)
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.7)
          Text(item.trainNumber)
            .fontSize(12)
            .fontColor('#000')
            .opacity(0.5)
          Text(item.endLocation)
            .fontSize(10)
            .textAlign(TextAlign.End)
            .fontColor('#000')
            .opacity(0.7)
        }
        .margin({ top: 2 })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

      }
      .layoutWeight(1)
      .margin({ right: 12 })

    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .margin({ bottom: 10 })
  }

  //火车票票单程数据列表
  @Builder
  contentTrainList() {
    List({ space: 12 }) {
      ForEach(this.listTrain.dataArray, (item: TrainTicketPriceListModel, index: number) => {
        ListItem() {
          Column() {
            this.oneWay(item)

            Row() {
              Text() {
                Span('二等 ')
                  .fontSize(10)
                  .fontColor('#80000000')
                Span(item.secondClass)
                  .fontSize(10)
                  .fontColor('#30B072')

              }
              .textAlign(TextAlign.Start)

              Text() {
                Span('一等 ')
                  .fontSize(10)
                  .fontColor('#80000000')
                Span(item.firstClass)
                  .fontSize(10)
                  .fontColor('#30B072')

              }
              .textAlign(TextAlign.Start)

              Text() {
                Span('商务 ')
                  .fontSize(10)
                  .fontColor('#80000000')
                Span(item.businessClass)
                  .fontSize(10)
                  .fontColor('#FF4A26')

              }
              .textAlign(TextAlign.Start)

              Text() {
                Span('无座 ')
                  .fontColor('#80000000')
                  .fontSize(10)
                Span(item.noSeat)
                  .fontColor('#30B072')
                  .fontSize(10)
              }
              .textAlign(TextAlign.Start)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

          }
          .onClick(() => {
            if (!this.startTimeSafeCheck(this.goDate, item.startDate)) {
              return
            }
            if (!this.goEndTimeSafeCheck(this.planeListPriceData.planeBack.startDate, item.endDate)) {
              return
            }
            let data = this.addPlaneDetailData(item)
            data.type = 0
            data.weekDate = this.goWeek
            data.timeDate = this.goDate
            this.planeListPriceData.planeGo = data
            phoneRouterControl.jumpPage({
              pageName: RouterMap.PLANE_DETAIL_PAGE,
              builder: wrapBuilder(PlaneDetailPageBuilder),
              param: this.planeListPriceData
            })
          })
          .padding(12)
          .width('100%')
          .borderRadius(12)
          .backgroundColor('#fff')
        }
      },
        (item: TrainTicketPriceListModel, index: number) => `${item.startLocation}_${index}_${item.id}`)
    }
    .margin({ top: 10, bottom: 10 })
    .layoutWeight(1)
    .backgroundColor('#F2F2F2')
    .padding({ left: 16, right: 16 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }

  //火车票返程top日期栏
  @Builder
  contentTrainReturn() {
    List({ space: 10, scroller: this.listReturnScroller }) {
      ForEach(this.vmType.currentReturn === true ? this.vmTrain : this.vmTrainReturn,
        (item: TrainTicketPriceModel, index: number) => {
          ListItem() {
            Column() {
              this.dateCellBuilder(item.date, item.dateCode, item.price)
            }
            .borderRadius(12)
            .padding({ top: 4, bottom: 4 })
            .backgroundColor(this.returnIndex === index ? '#FEE231' : '#fff')
            .alignItems(HorizontalAlign.Center)
            .width(this.dataInfo.returnSatus === 1 ? 49 : 57)
            .onClick(() => {
              this.backStatus = false;
              if (this.dataInfo.returnSatus === 1 && this.goDateTime > 0 && item.dateNumber &&
                item.dateNumber < this.goDateTime) {
                promptAction.showToast({ message: '返程日期不得早于去程日期' });
                return
              }
              this.returnIndex = index
              this.backDate = item.dateCode
              this.backWeek = item.date
              this.hotelDateModel.checkOutDate = this.getISODate(this.backDate)
              this.backDateTime = item.dateNumber ?? 0
              this.returnListIndex = 0;
              this.backPrice = 0;
              this.returnPrice = 0;
              this.returnListIndex = null;
            })
          }
          .width(57)
          .height(51)
        }, (item: TrainTicketPriceModel) => item.id?.toString())
    }
    .backgroundColor('#fff')
    .padding({ left: 4, right: 4 })
    .height(67)
    .layoutWeight(1)
    .alignListItem(ListItemAlign.Center)
    .listDirection(Axis.Horizontal)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }

  // 火车票列表详情
  @Builder
  ticketDetail(item: TrainTicketPriceListModel) {
    Column() {
      this.roundTrip(item)

      Row() {
        if (this.collapseExpandState) {
          Row() {
            Text() {
              Span('二等 ')
                .fontSize(10)
                .fontColor('#80000000')
              Span(item.secondClass)
                .fontSize(10)
                .fontColor('#30B072')
            }

            Text() {
              Span('一等 ')
                .fontSize(10)
                .fontColor('#80000000')
              Span(item.firstClass)
                .fontSize(10)
                .fontColor('#30B072')

            }

            Text() {
              Span('商务 ')
                .fontSize(10)
                .fontColor('#80000000')
              Span(item.businessClass)
                .fontSize(10)
                .fontColor('#30B072')
            }

            Text() {
              Span('无座 ')
                .fontColor('#80000000')
                .fontSize(10)
              Span(item.noSeat)
                .fontColor('#30B072')
                .fontSize(10)
            }

          }
          .layoutWeight(1).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
        } else {
          Column() {
            Row() {
              Text() {
                Span('二等 ')
                  .fontSize(10)
                  .fontColor('#80000000')
                Span(item.secondClass)
                  .fontSize(10)
                  .fontColor('#30B072')

              }
              .width('50%')
              .textAlign(TextAlign.Start)

              Text() {
                Span('一等 ')
                  .fontSize(10)
                  .fontColor('#80000000')
                Span(item.firstClass)
                  .fontSize(10)
                  .fontColor('#30B072')

              }
              .width('50%')
              .textAlign(TextAlign.End)
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 4 })

            Row() {
              Text() {
                Span('商务 ')
                  .fontSize(10)
                  .fontColor('#80000000')
                Span(item.businessClass)
                  .fontSize(10)
                  .fontColor('#30B072')

              }
              .width('50%')
              .textAlign(TextAlign.Start)

              Text() {
                Span('无座 ')
                  .fontColor('#80000000')
                  .fontSize(10)
                Span(item.noSeat)
                  .fontColor('#30B072')
                  .fontSize(10)
              }
              .width('50%')
              .textAlign(TextAlign.End)
            }
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .layoutWeight(1)

        }

        Column() {
          Text('¥' + item.price)
            .fontColor('#FF4A26')
            .fontSize(18)
        }
        .width(60)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

    }
    .layoutWeight(1)
    .height(90)
    .padding({ top: 12, left: 12 })
  }

  //火车票返程数据列表
  @Builder
  contentListTrainReturn(list: TrainTicketPriceListModel[]) {
    List() {
      ForEach(list, (item: TrainTicketPriceListModel, index: number) => {
        ListItem() {
          Row() {
            this.ticketDetail(item)
          }
          .onClick(() => {
            if (!this.backStartTimeSafeCheck(item.startDate, this.planeListPriceData.planeGo.endDate)) {
              return
            }
            let data = this.addPlaneDetailData(item)
            data.weekDate = this.backWeek
            data.timeDate = this.backDate
            data.type = 1
            this.backPrice = Number(item.price)
            this.returnPrice = this.backPrice + this.goPrice
            this.returnListIndex = index
            this.planeListPriceData.planeBack = data
            this.backStatus = true
          })
          .padding({ bottom: 10 })
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)
          .backgroundColor(this.returnListIndex === index ? '#FFFBE4' : '#fff')
        }
      },
        (item: TrainTicketPriceListModel,
          index: number) => `${index}_${item.id}`)
    }
    .layoutWeight(1)
    .backgroundColor('#fff')
    .padding({ left: 8, right: 8 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }

  //火车票去程数据列表
  @Builder
  contentListTrainOutbound(list: TrainTicketPriceListModel[]) {
    List() {
      ForEach(list, (item: TrainTicketPriceListModel, index: number) => {
        ListItem() {
          Row() {
            this.ticketDetail(item)
          }
          .onClick(() => {
            if (!this.startTimeSafeCheck(this.goDate, item.startDate)) {
              return
            }
            if (!this.goEndTimeSafeCheck(this.planeListPriceData.planeBack.startDate, item.endDate)) {
              return
            }
            let data = this.addPlaneDetailData(item)
            data.weekDate = this.goWeek
            data.timeDate = this.goDate
            data.type = 1
            this.goPrice = Number(item.price)
            this.returnPrice = this.backPrice + this.goPrice
            this.outboundListIndex = index
            this.planeListPriceData.planeGo = data
            this.goStatus = true
          })
          .padding({ bottom: 10 })
          .width('100%')
          .backgroundColor(this.outboundListIndex === index ? '#FFFBE4' : '#fff')
          .justifyContent(FlexAlign.SpaceAround)
        }
      },
        (item: TrainTicketPriceListModel,
          index: number) => `${index}_${item.id}`)
    }
    .layoutWeight(1)
    .backgroundColor('#fff')
    .padding({ left: 8, right: 8 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }

  //汽车票单程top日期栏
  @Builder
  contentCar() {
    List({ space: 8, scroller: this.listScroller }) {
      ForEach(this.vmType.currentReturn === true ? this.vmTrainReturn : this.vmCar,
        (item: TrainTicketPriceModel, index: number) => {
          ListItem() {
            Column() {
              this.dateCellBuilder(item.date, item.dateCode, item.price)
            }
            .borderRadius(12)
            .padding({ top: 4, bottom: 4 })
            .backgroundColor(this.outboundIndex === index ? '#FEE231' : '#fff')
            .alignItems(HorizontalAlign.Center)
            .width(this.dataInfo.returnSatus === 1 ? 49 : 57)
            .onClick(() => {
              this.outboundIndex = index
              this.goDate = item.dateCode
              this.goWeek = item.date
              this.hotelDateModel.checkInDate = this.getISODate(this.goDate)
              if (this.vmType.currentReturn === false && index > 2) {
                this.listScroller.scrollToIndex(index - 2)
              }
            })
          }
          .width(57)
          .height(67)
        }, (item: TrainTicketPriceModel) => item.id?.toString())
    }
    .backgroundColor('#fff')
    .padding({ left: 20, right: 4 })
    .height(67)
    .alignListItem(ListItemAlign.Center)
    .layoutWeight(1)
    .listDirection(Axis.Horizontal)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }

  //汽车票单程数据列表
  @Builder
  contentCarList() {
    List({ space: 12 }) {
      ForEach(this.listCar.dataArray, (item: TrainTicketPriceListModel, index: number) => {
        ListItem() {
          Row() {
            Column() {
              Text('发车')
                .fontSize(14)
                .opacity(0.7)
                .fontColor('#000')

              Text(item.startDate)
                .fontSize(18)
                .fontColor('#000')
                .margin({ top: 6, bottom: 14 })
              Text('约' + item.duration)
                .fontSize(10)
                .fontColor('#000')
                .opacity(0.5)
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ right: 40 })

            Row() {
              Row() {
                Image($r('app.media.ic_car_line'))
                  .width(4)
              }
              .margin({ right: 8 })

              Column() {
                Text(item.startLocation)
                  .fontSize(14)
                  .fontColor('#000')
                  .margin({ bottom: 8 })
                Text(item.endLocation)
                  .fontSize(14)
                  .fontColor('#000')
              }
            }
            .height('100%')
            .alignItems(VerticalAlign.Top)

            Column() {
              Text() {
                Span('¥')
                  .fontSize(14)
                  .fontWeight(500)
                Span(item.price)
                  .fontSize(20)
                  .fontWeight(500)
              }
              .fontColor('#FF4A26')

              Text(item.noSeat)
                .fontSize(10)
                .fontColor('#FF4A26')
            }
            .height('100%')
            .alignItems(HorizontalAlign.End)
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .onClick(() => {
            if (!this.startTimeSafeCheck(this.goDate, item.startDate)) {
              return
            }
            let data = this.addPlaneDetailData(item)
            data.chooseStatus = 2
            data.type = 0
            data.weekDate = this.goWeek
            data.timeDate = this.goDate
            phoneRouterControl.jumpPage({
              pageName: RouterMap.CAR_DETAIL_PAGE,
              builder: wrapBuilder(CarDetailPageBuilder),
              param: data
            })
          })
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({
            top: 12,
            bottom: 12,
            left: 16,
            right: 16
          })
          .width('100%')
          .height(88)
          .borderRadius(12)
          .backgroundColor('#fff')
        }
      },
        (item: TrainTicketPriceListModel, index: number) => `${item.startLocation}_${index}_${item.id}`)
    }
    .margin({ top: 10, bottom: 10 })
    .layoutWeight(1)
    .backgroundColor('#F2F2F2')
    .padding({ left: 16, right: 16 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }

  //单程及去程日期
  @Builder
  calendarIconBuilder() {
    Column() {
      Image($r('app.media.ic_date'))
        .width(20)
        .height(20)
        .margin({ bottom: 4 })
      Text('日历')
        .fontSize(10)
    }
    .onClick(() => {
      CalendarPickerUtil.show({
        type: TypePicker.SINGLE,
        dialogType: DialogType.SHEET,
        swiperDirection: SwiperDirection.HORIZONTAL,
        startYear: this.today.getFullYear(),
        rangeLimit: [this.hotelDateModel.startDate],
        endYear: this.today.getFullYear() + 1,
        detents: [SheetSize.MEDIUM],
        selected: this.getISODate(this.goDate),
        onSelected: (date: Date | Date[]) => {
          this.handleConfirmData(date);
        }
      })
    })
  }

  //返程日期
  @Builder
  calendarIconBuilderReturn() {
    Column() {
      Image($r('app.media.ic_date'))
        .width(20)
        .height(20)
        .margin({ bottom: 4 })
      Text('日历')
        .fontSize(10)
    }
    .onClick(() => {
      CalendarPickerUtil.show({
        type: TypePicker.SINGLE,
        dialogType: DialogType.SHEET,
        swiperDirection: SwiperDirection.HORIZONTAL,
        startYear: this.today.getFullYear(),
        rangeLimit: [this.hotelDateModel.startDate],
        endYear: this.today.getFullYear() + 1,
        detents: [SheetSize.MEDIUM],
        selected: this.getISODate(this.backDate),
        onSelected: (date: Date | Date[]) => {
          this.handleConfirmDataReturn(date);
        }
      })
    })
  }

  //更换单程地点日期
  @Builder
  singleTripDateSelector() {
    Row() {
      Row() {
        Text(this.hotelDateModel.getDateLabel(this.hotelDateModel.checkInDate))
          .mainLabelStyle()
        Text(this.dataInfo.goWeek)
          .fontSize(14)
          .opacity(0.5)
          .margin({ left: 4 })
      }.alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)

    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      CalendarPickerUtil.show({
        type: TypePicker.SINGLE,
        dialogType: DialogType.SHEET,
        swiperDirection: SwiperDirection.VERTICAL,
        startYear: this.today.getFullYear(),
        rangeLimit: [this.hotelDateModel.startDate],
        endYear: this.today.getFullYear() + 1,
        detents: [SheetSize.MEDIUM],
        selected: this.getISODate(this.goDate),
        onSelected: (date: Date | Date[]) => {
          this.handleConfirmData(date);
        }
      })
    })
  }

  // 更换往返地点日期
  @Builder
  roundTripDateSelector() {
    Row() {
      Row() {
        Text(this.hotelDateModel.getDateLabel(this.hotelDateModel.checkInDate))
          .mainLabelStyle()
        Text(this.dataInfo.goWeek)
          .fontSize(14)
          .opacity(0.5)
          .margin({ left: 4 })
      }.alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)

      Text(this.hotelDateModel.totalDays + '天').fontSize(14).fontColor('#333333')

      Row() {
        Text(this.hotelDateModel.getDateLabel(this.hotelDateModel.checkOutDate))
          .mainLabelStyle()
        Text(this.dataInfo.goWeek)
          .fontSize(14)
          .opacity(0.5)
          .margin({ left: 4 })
      };
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      CalendarPickerUtil.show({
        type: TypePicker.RANGE,
        dialogType: DialogType.SHEET,
        swiperDirection: SwiperDirection.VERTICAL,
        startYear: this.today.getFullYear(),
        rangeLimit: [this.hotelDateModel.startDate],
        endYear: this.today.getFullYear() + 1,
        detents: [SheetSize.MEDIUM],
        selectDates: [this.getISODate(this.goDate), this.getISODate(this.backDate)],
        onSelected: (date: Date | Date[]) => {
          this.handleConfirm(date);
        }
      })
    })
  }

  @Builder
  dateCellBuilder(date: string, dateCode: string, price: string) {
    Column() {
      Text(date)
        .fontSize(12)
        .fontColor('#000')
        .opacity(0.7)
        .lineHeight(12)
      Text(dateCode)
        .fontSize(16)
        .fontColor('#333')
        .lineHeight(19)
      Text('¥' + price)
        .fontSize(12)
        .lineHeight(12)
        .fontColor('#000')
        .opacity(0.7)
    }
  }
}

@Extend(Text)
function mainLabelStyle() {
  .fontSize(18)
  .lineHeight(21)
  .fontWeight(500);
}