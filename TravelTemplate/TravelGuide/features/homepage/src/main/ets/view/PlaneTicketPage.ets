/**
 * @usage: 机票/火车票/汽车票预订页面，支持单程和往返模式，提供出发城市、到达城市选择，日期选择，出行人选择功能
 * @layout: 页面整体采用Stack布局，背景图片在底层，上方是返回按钮和票务tabs切换卡片，卡片内包含单程/往返切换、
 * 城市选择、日期选择、出行人选择、查询按钮
 * @constraints: chooseStatus控制当前模式（Aircraft机票、Train火车票、Bus汽车票）；returnSatus控制单程或往返；
 * selectPeopleList管理已选出行人
 * @isGen: true
 * @fileType: page
 * @zhName: 机票火车票预订
 * @domain: 旅游
 * @image: screenshots/homepage/PlaneTicket.jpg
 * @subPage: CitySelectPage,TicketPricesPage,TravelPeopleListPage
 */
import { DialogType, SwiperDirection, TypePicker, UICalendarPicker } from '@hw-agconnect/ui-calendar-picker';
import { BarVM, BreakpointModel, RouterMap, TValueType } from 'common';
import { phoneRouterControl } from 'oh_router';
import { CitySelectPageBuilder } from './CitySelectPage';
import { AppStorageV2, PersistenceV2, promptAction } from '@kit.ArkUI';
import { TicketPricesPageBuilder } from './TicketPricesPage';
import {
  ChooseStatus,
  HotelDateModel,
  MockTicketPriceService,
  MockTicketReturnPriceService,
  MockTrainTicketPriceService,
  MockTrainTicketReturnPriceService,
  MockTravelerService,
  PlanePageVM,
  TravelPeopleListModel,
  TravelPeopleModel,
  TripType
} from 'common_travel_guide';
import { City } from 'city_select';
import { TravelPeopleListPageBuilder } from './TravelPeopleListPage';
import { GridRowColSetting } from 'common/src/main/ets/constant/GridRowColSetting';

@Builder
export function PlaneTicketPageBuilder(param: TValueType) {
  PlaneTicketPage({
    pageParam: param
  })
}

export interface TicketParam {
  vm: PlanePageVM
  hotelDateModel: HotelDateModel
}

@ComponentV2
export struct PlaneTicketPage {
  @Param pageParam: TValueType = null
  @Local dataInfo: string = this.pageParam as string
  vm: PlanePageVM = new PlanePageVM()
  logTag: string = 'HotelPage';
  @Param showTopLabel: boolean = true;
  @Local today: Date = new Date()
  @Local selectTraveler: string = ''
  @Local goCity: string = '北京市'
  @Local backCity: string = '上海市'
  @Local selectTravelerId: string = ''
  @Local hotelDateModel: HotelDateModel = new HotelDateModel()
  @Local selectPeopleList: TravelPeopleModel[] = [];
  @Local peopleList: TravelPeopleListModel =
    PersistenceV2.connect(TravelPeopleListModel, 'TravelPeopleList', () => new TravelPeopleListModel())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // 是否折叠屏展开状态
  @Local collapseExpandState: boolean = GridRowColSetting.checkColumnCountModel();

  @Monitor('breakPointModel.currentBreakpoint')
  breakPointChange() {
    this.collapseExpandState = GridRowColSetting.checkColumnCountModel()
  }

  @Event paramChangeCallback: (data: HotelDateModel) => void = () => {
    if (this.hotelDateModel.checkInDate) {
      this.vm.startDate =
        `${this.hotelDateModel.checkInDate.getMonth() + 1}-${this.hotelDateModel.checkInDate.getDate()}`
      this.vm.startYear = this.hotelDateModel.checkInDate.getFullYear()
    }
    if (this.hotelDateModel.checkOutDate) {
      this.vm.endDate =
        `${this.hotelDateModel.checkOutDate.getMonth() + 1}-${this.hotelDateModel.checkOutDate.getDate()}`
      this.vm.endYear = this.hotelDateModel.checkOutDate.getFullYear()
    }
    this.vm.backWeek = this.getWeekday(this.today.getFullYear() + '-' + this.vm.endDate)
    this.vm.goWeek = this.getWeekday(this.today.getFullYear() + '-' + this.vm.startDate)
  };

  aboutToAppear(): void {
    this.vm.backWeek = this.getWeekday(this.today.getFullYear() + '-' + this.vm.endDate)
    this.vm.goWeek = this.getWeekday(this.today.getFullYear() + '-' + this.vm.startDate)
    if (this.dataInfo === '机票') {
      this.vm.chooseStatus = 0
    } else if (this.dataInfo === '火车票') {
      this.vm.chooseStatus = 1
    } else {
      this.vm.chooseStatus = 2
    }

    MockTravelerService.init()
    MockTicketPriceService.init()
    MockTrainTicketPriceService.init()
    MockTrainTicketReturnPriceService.init()
    MockTicketReturnPriceService.init()
    this.vm.startYear = this.hotelDateModel.checkInDate.getFullYear()
    this.vm.endYear = this.hotelDateModel.checkOutDate.getFullYear()
  }

  getWeekday(dateString: string) {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const date = new Date(dateString);
    const weekday = date.getDay();
    return weekdays[weekday];
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

  public handleConfirm(date: Date | Date[]) {
    let dates: Date[] = date as Date[];
    this.hotelDateModel.checkInDate = dates[0];
    this.hotelDateModel.checkOutDate = dates[1];
    this.paramChangeCallback?.(this.hotelDateModel)
  }

  public handleConfirmData(date: Date | Date[]) {
    let dates: Date = date as Date;
    this.hotelDateModel.checkInDate = dates;
    this.paramChangeCallback?.(this.hotelDateModel)
  }

  @Builder
  render() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.ic_plane_ticket')).width('100%').objectFit(ImageFit.Contain)
      Column() {
        Row() {
          Image($r('app.media.ic_back_white'))
            .width(40)
            .height(40)
            .onClick(() => {
              phoneRouterControl.popPage()
              return true
            })
        }
        .width('100%')
        .margin({ top: BarVM.instance.staBarH, bottom: this.collapseExpandState ? 105 : 55 })
        .justifyContent(FlexAlign.Start)

        Column() {
          this.topMenu()
          this.seachButton()
        }.width(this.collapseExpandState ? '70%' : '100%')

      }.margin({ left: 16, right: 16 })
    }
  }

  @Builder
  seachButton() {
    Column() {
      Row() {
        Row() {
          Text('单程')
        }
        .onClick(() => {
          this.vm.returnSatus = TripType.OneWay
        })
        .width(152)
        .height(26)
        .justifyContent(FlexAlign.Center)
        .borderRadius(6)
        .backgroundColor(this.vm.returnSatus === TripType.OneWay ? '#ffffff' : 'rgba(0, 0, 0, 0)')

        Row() {
          Text('往返')
        }
        .onClick(() => {
          this.vm.returnSatus = TripType.Return
          this.hotelDateModel.checkInDate = new Date()
          this.hotelDateModel.checkOutDate = new Date();
          this.hotelDateModel.checkOutDate.setDate(this.hotelDateModel.checkInDate.getDate() + 1)
          this.vm.startYear = this.hotelDateModel.checkInDate.getFullYear()
          this.vm.endYear = this.hotelDateModel.checkOutDate.getFullYear()
        })
        .justifyContent(FlexAlign.Center)
        .width(152)
        .height(26)
        .borderRadius(6)
        .backgroundColor(this.vm.returnSatus === TripType.Return ? '#ffffff' : 'rgba(0, 0, 0, 0)')
      }
      .margin({ top: 12, bottom: 26 })
      .width(308)
      .height(30)
      .borderRadius(6)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#EDF0F2')
      .visibility(this.vm.chooseStatus === ChooseStatus.Bus ? Visibility.None : Visibility.Visible)

      this.selectCut()

      if (this.vm.returnSatus === TripType.Return && this.vm.chooseStatus !== ChooseStatus.Bus) {
        this.datesPickerBuilder()
      } else {
        this.datePickerBuilder()
      }
      Row() {
        Text(this.selectTraveler ? this.selectTraveler : '选择出行人')
          .fontColor('#333')
        Image($r('app.media.traveler'))
          .width(14)
          .height(14)
      }
      .width('100%')
      .margin({ top: 28, bottom: 28 })
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        // 跳转到出行人列表
        phoneRouterControl.jumpPage({
          pageName: RouterMap.TRAVEL_PEOPLE_LIST_PAGE,
          builder: wrapBuilder(TravelPeopleListPageBuilder),
          param: this.selectPeopleList,
          onPop: (popInfo: PopInfo) => {
            let result = this.peopleList.list.filter((item: TravelPeopleModel) => item.isCheck)
            this.selectPeopleList = result;
            this.vm.selectTravelerId = this.selectPeopleList
            this.selectTraveler = `已选${this.selectPeopleList.length}人`
          }
        })
      })

      Row() {
        Text('查询')
          .fontSize(16)
          .fontColor('#333')
      }
      .onClick(() => {
        let data: TicketParam =  {
          vm: this.vm,
          hotelDateModel: this.hotelDateModel
        }
        phoneRouterControl.jumpPage({
          pageName: RouterMap.TICKET_PRICES_PAGE,
          builder: wrapBuilder(TicketPricesPageBuilder),
          param: data
        })
      })
      .width('100%')
      .backgroundColor('#FEE641')
      .borderRadius(24)
      .height(43)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .backgroundColor('#ffffff')
    .padding({ left: 12, right: 12, bottom: 12 })
    .borderRadius({ bottomLeft: 16, bottomRight: 16 })
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  selectCut() {
    Row() {
      Row() {
        Text(this.goCity)
      }
      .width(137)
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.CITY_SELECT_PAGE,
          builder: wrapBuilder(CitySelectPageBuilder),
          param: this.vm.currentCity,
          onPop: (popInfo: PopInfo) => {
            let result = popInfo?.result as City;
            if (result && result.name) {
              this.vm.currentCity1 = result.name as string
              this.vm.currentCity = result.name as string
              this.goCity = result.name
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
        this.vm.currentReturn = !this.vm.currentReturn
        if (this.vm.currentReturn === true) {
          this.vm.currentCity = this.vm.returnCity1
          this.vm.returnCity = this.vm.currentCity1
          this.goCity = this.vm.returnCity1
          this.backCity = this.vm.currentCity1
        } else {
          this.vm.currentCity = this.vm.currentCity1
          this.vm.returnCity = this.vm.returnCity1
          this.goCity = this.vm.currentCity1
          this.backCity = this.vm.returnCity1
        }

      })

      Row() {
        Text(this.backCity)
      }
      .width(137)
      .justifyContent(FlexAlign.End)
      .onClick(() => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.CITY_SELECT_PAGE,
          builder: wrapBuilder(CitySelectPageBuilder),
          param: this.vm.returnCity,
          onPop: (popInfo: PopInfo) => {
            let result = popInfo?.result as City;
            if (result && result.name) {
              this.backCity = result.name as string
              this.vm.returnCity1 = result.name as string
              this.vm.returnCity = result.name as string
            }
          }
        })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .margin({ bottom: 28, top: this.vm.chooseStatus === ChooseStatus.Bus ? 26 : 0 })
  }

  @Builder
  topMenu() {
    Row() {
      if (this.vm.chooseStatus === ChooseStatus.Aircraft) {
        Stack({ alignContent: Alignment.Center }) {
          Image($r('app.media.ic_domestic')).width('45%').objectFit(ImageFit.Contain)
          Row() {
            Text('机票')
              .fontSize(16)
              .fontColor(this.vm.chooseStatus === ChooseStatus.Aircraft ? '#000000' : 'rgba(0, 0, 0, 0.50)')
              .onClick(() => {
                this.vm.chooseStatus = ChooseStatus.Aircraft
                this.vm.currentReturn = false
              })

          }.width('33.3%').justifyContent(FlexAlign.SpaceAround).alignItems(VerticalAlign.Center)
        }
      } else {
        Row() {
          Text() {
            Span('机票')
              .fontSize(16)
              .fontColor(this.vm.chooseStatus === ChooseStatus.Aircraft ? '#000000' : 'rgba(0, 0, 0, 0.50)')
              .onClick(() => {
                this.vm.chooseStatus = ChooseStatus.Aircraft
                this.vm.currentReturn = false
              })
          }

        }.width('36%').justifyContent(FlexAlign.Center)
      }
      if (this.vm.chooseStatus === ChooseStatus.Train) {
        Stack({ alignContent: Alignment.Center }) {
          Image($r('app.media.ic_hourly_room')).width('41%').objectFit(ImageFit.Contain)
          Row() {
            Text('火车票')
              .fontSize(16)
              .fontColor(this.vm.chooseStatus === ChooseStatus.Train ? '#000000' : 'rgba(0, 0, 0, 0.50)')
          }.width('33.3%').justifyContent(FlexAlign.Center)
        }
      } else {
        Row() {
          Text('火车票')
            .fontSize(16)
            .fontColor(this.vm.chooseStatus === ChooseStatus.Train ? '#000000' : 'rgba(0, 0, 0, 0.50)')
        }
        .width('19%')
        .justifyContent(this.vm.chooseStatus === ChooseStatus.Bus ? FlexAlign.Center : FlexAlign.Start)
        .onClick(() => {
          this.vm.chooseStatus = ChooseStatus.Train
          this.vm.currentReturn = false
        })
      }

      if (this.vm.chooseStatus === ChooseStatus.Bus) {
        Stack({ alignContent: Alignment.Center }) {
          Image($r('app.media.ic_homestay')).width('36%').objectFit(ImageFit.Contain)
          Row() {
            Text('汽车票')
              .fontSize(16)
              .fontColor(this.vm.chooseStatus === ChooseStatus.Bus ? '#000000' : 'rgba(0, 0, 0, 0.50)')
          }.width('33.3%').justifyContent(FlexAlign.Center)

        }
      } else {
        Row() {
          Text('汽车票')
            .fontSize(16)
            .fontColor(this.vm.chooseStatus === ChooseStatus.Bus ? '#000000' : 'rgba(0, 0, 0, 0.50)')
        }
        .width(this.vm.chooseStatus === ChooseStatus.Train ? '26%' : '36%')
        .justifyContent(this.vm.chooseStatus === ChooseStatus.Train ? FlexAlign.Start : FlexAlign.Center)
        .onClick(() => {
          this.vm.returnSatus = 0
          this.vm.chooseStatus = ChooseStatus.Bus
          this.vm.currentReturn = false
        })
      }

    }
    .backgroundColor('rgba(255, 255, 255, 0.8)')
    .width('100%')
    .borderRadius({ topLeft: 16, topRight: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  datesPickerBuilder() {
    UICalendarPicker({
      type: TypePicker.RANGE,
      dialogType: DialogType.SHEET,
      swiperDirection: SwiperDirection.VERTICAL,
      startYear: this.today.getFullYear(),
      rangeLimit: [this.hotelDateModel.startDate],
      endYear: this.today.getFullYear() + 1,
      detents: [SheetSize.MEDIUM],
      selectDates: [this.hotelDateModel.checkInDate, this.hotelDateModel.checkOutDate],
      onSelected: (date: Date | Date[]) => {
        this.handleConfirm(date);
      },
    }) {
      Row() {
        Row() {
          Text(this.hotelDateModel.getDateLabel(this.hotelDateModel.checkInDate))
            .mainLabelStyle()
          Text(this.vm.goWeek)
            .margin({ left: 4 })
            .fontSize(14)
            .opacity(0.5)
        }.alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)

        Text(this.hotelDateModel.totalDays + '天').fontSize(14).fontColor('#333333')

        Row() {
          Text(this.hotelDateModel.getDateLabel(this.hotelDateModel.checkOutDate))
            .mainLabelStyle()
          Text(this.vm.backWeek)
            .fontSize(14)
            .opacity(0.5)
            .margin({ left: 4 })
        };
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
  }

  //单程日期
  @Builder
  datePickerBuilder() {
    UICalendarPicker({
      type: TypePicker.SINGLE,
      dialogType: DialogType.SHEET,
      swiperDirection: SwiperDirection.VERTICAL,
      startYear: this.today.getFullYear(),
      rangeLimit: [this.hotelDateModel.startDate],
      endYear: this.today.getFullYear() + 1,
      detents: [SheetSize.MEDIUM],
      selected: this.hotelDateModel.checkInDate,
      onSelected: (date: Date | Date[]) => {
        this.handleConfirmData(date);
      },
    }) {
      Row() {
        Row() {
          Text(this.hotelDateModel.getDateLabel(this.hotelDateModel.checkInDate))
            .mainLabelStyle()
          Text(this.vm.goWeek)
            .fontSize(14)
            .opacity(0.5)
            .margin({ left: 4 })
        }.alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
  }
}

@Extend(Text)
function mainLabelStyle() {
  .fontSize(18)
  .lineHeight(21)
  .fontWeight(500);
}