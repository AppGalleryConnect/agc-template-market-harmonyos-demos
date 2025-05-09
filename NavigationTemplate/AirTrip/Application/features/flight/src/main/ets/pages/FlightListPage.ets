import { AppRouter, Constants,
  DataStorage,
  DayFormat,
  DayInfo,
  getDayLabel,
  LoadingStatus,
} from 'common'
import { AppStorageV2 } from '@kit.ArkUI'
import { FlightInfo, FlightListResult, SortBy } from '../model/FlightPageModel';
import { FlightApi } from '../api/FlightApi';
import { getFlyDuration, isNextDay } from '../utils/FlightUtil';
import { GlobalDialog, DayList, BaseTitle, BaseTip } from 'components'

@Builder
export function flightListPageBuilder() {
  FlightListPage()
}

@ComponentV2
export struct FlightListPage {
  // 应用全局UI状态存储
  @Local dataStorage: DataStorage = AppStorageV2.connect(DataStorage, 'DataStorage', () => new DataStorage())!
  // 当前月视图或周视图中选中的日期
  @Local currentSelectDay: DayInfo =
    new DayInfo(new Date().getFullYear(), new Date().getMonth() + 1, new Date().getDate(), getDayLabel(new Date()));
  @Local loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @Local isRefreshing: boolean = false
  @Local flightList: FlightInfo[] = []
  // 按照什么来排序，默认按照价格升序排序
  @Local sortBy: SortBy = SortBy.PRICE
  @Local sortType: string = 'asc'
  @Local isShowTipMode: boolean = false

  openLoadingDialog() {
    // Loading
    GlobalDialog.showLoadingDialog({
      maskRect: {
        width: '100%',
        height: '90%',
        x: 0,
        y: '10%',
      },
    })
  }

  getFlightList(day?: DayInfo) {
    this.openLoadingDialog()
    this.loadingStatus = LoadingStatus.LOADING;
    let dateTime = `${this.currentSelectDay.year}/${this.currentSelectDay.month}/${this.currentSelectDay.date} 08:00`
    let departureCity = this.dataStorage.departureCity?.cityName ?? ''
    let destinationCity = this.dataStorage.destinationCity?.cityName ?? ''
    // 实际的时间
    let departureDate = new DayFormat(dateTime).format('YYYY/MM/DD');
    let params: Record<string, string> = {
      'departureCity': departureCity,
      'destinationCity': destinationCity,
      'departureDate': '2025/04/09', // 当前只有这个时间能查到数据
    };
    FlightApi.getFlightSearchList(params).then((res) => {
      GlobalDialog.close()
      let result = res.result as FlightListResult;
      if (result.ret.code === 0) {
        /*
         * 正常数据：this.flightList = result.result as FlightInfo[] || [];
         * mock的数据
         * */
        this.flightList = (result.result as FlightInfo[] || []).map((flight: FlightInfo) => {
          let start = flight.takeoffTime.split(' ');
          let end = flight.landingTime.split(' ');
          flight.takeoffTime = departureDate + ' ' + start[1];

          if (end[0] === start[0]) {
            flight.landingTime = departureDate + ' ' + end[1];
          } else {
            let pre = new Date(dateTime).getTime() + 24 * 60 * 60 * 1000;
            flight.landingTime = new DayFormat(new Date(pre)).format('YYYY/MM/DD') + ' ' + end[1];
          }
          return flight;
        })
        // 这里使用前台排序，实际可以使用后台排序
        this.sortFlightList()

        // 获取最低价
        let lowPrice = 0
        if (this.flightList.length) {
          let priceList = this.flightList.map((flight: FlightInfo) => Number(flight.lowestPrice))
          lowPrice = Math.min(...priceList)
        }
        if (day) {
          day.currentDayFlightLowPrice = lowPrice
        } else {
          this.currentSelectDay.currentDayFlightLowPrice = lowPrice
        }
      }
      this.loadingStatus = this.flightList.length ? LoadingStatus.SUCCESS : LoadingStatus.EMPTY
      this.isRefreshing = false;
    }).catch(() => {
      GlobalDialog.close()
      this.loadingStatus = LoadingStatus.EMPTY;
      this.isRefreshing = false;
    })
  }

  sortFlightList() {
    this.flightList.sort((a: FlightInfo, b: FlightInfo): number => {
      if (this.sortBy === SortBy.PRICE) {
        let aPrice = Number(a.lowestPrice)
        let bPrice = Number(b.lowestPrice)
        return this.sortType === 'asc' ? aPrice - bPrice : bPrice - aPrice
      } else {
        let aTakeoffTime = new Date(a.takeoffTime).getTime()
        let bTakeoffTime = new Date(b.takeoffTime).getTime()
        return this.sortType === 'asc' ? aTakeoffTime - bTakeoffTime : bTakeoffTime - aTakeoffTime
      }
    })
  }

  getSortImg(): ResourceStr {
    return this.sortType === 'asc' ? $r('app.media.ic_sort_asc') : $r('app.media.ic_sort_desc')
  }

  @Builder
  DateListView() {
    Row() {
      Column() {
        DayList({
          currentSelectedDay: this.currentSelectDay,
          onDateClick: (day: DayInfo) => {
            this.currentSelectDay.year = day.year;
            this.currentSelectDay.month = day.month;
            this.currentSelectDay.date = day.date;
            this.currentSelectDay.weekDay = day.weekDay;
            this.dataStorage.departureDate = this.currentSelectDay

            this.getFlightList(day)
          },
        })
      }
      .layoutWeight(1)
      .padding({ left: 2 })
      .alignItems(HorizontalAlign.Start)

      Row() {
        Image($r('app.media.ic_calender')).width(24).height(24)
      }
      .width(46)
      .height(64)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .shadow({
        radius: 6,
        color: '#1a6c6c6c',
        offsetX: -10,
        offsetY: 6,
      })
      .onClick(() => {
        AppRouter.push({
          url: 'CalendarPage',
        })
      })
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.white'))
    .border({
      width: { bottom: 1 },
      color: { bottom: '#fffdfcfc' },
      style: BorderStyle.Solid,
    })
  }

  build() {
    NavDestination() {
      BaseTitle({
        title: '机票预订',
        showBackBtn: true,
        onBack: () => {
          AppRouter.pop()
        },
      })

      this.DateListView()

      if (this.loadingStatus === LoadingStatus.FAILED || this.loadingStatus === LoadingStatus.EMPTY) {
        this.EmptyBuilder()
      }
      if (this.loadingStatus === LoadingStatus.SUCCESS) {
        this.ListTopView()

        this.ListContent()
      }
    }
    .hideTitleBar(true)
    .onWillShow(() => {
      if (this.dataStorage.departureDate) {
        let date = this.dataStorage.departureDate
        this.currentSelectDay.year = date.year
        this.currentSelectDay.month = date.month
        this.currentSelectDay.date = date.date
      }
      this.getFlightList()
    })
  }

  @Builder
  ListContent() {
    Refresh({ refreshing: $$this.isRefreshing }) {
      List({ space: 8 }) {
        // 列表数据
        ForEach(this.flightList, (item: FlightInfo) => {
          ListItem() {
            this.FlightItemView(item)
          }
        })

        ListItem() {
          Row() {
            Text('我也是有底线的').fontColor('#ffacacac').fontSize(12)
          }
          .width(Constants.FULL_PERCENT_WIDTH)
          .padding({ top: 10, bottom: 20 })
          .justifyContent(FlexAlign.Center)
        }
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .height(Constants.FULL_PERCENT_HEIGHT)
      .padding({ left: 16, right: 16 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
    }
    .onRefreshing(() => {
      this.getFlightList()
    })
    .pullToRefresh(true)
    .width(Constants.FULL_PERCENT_WIDTH)
    .layoutWeight(1)
    .backgroundColor('#fff5f3f3')
  }

  @Builder
  FlightItemView(item: FlightInfo) {
    Column({ space: 10 }) {
      Row({ space: 8 }) {
        Image($r('app.media.ic_air_logo')).width(24).height(24)
        Row({ space: 4 }) {
          Text(item.airlineName).fontSize(12).fontWeight(FontWeight.Medium)
          Text(item.flightNo + item.aircraftType).fontSize(8).fontColor('#99000000')
        }
      }
      .width(Constants.FULL_PERCENT_WIDTH)

      Row() {
        Column({ space: 4 }) {
          Text(new DayFormat(item.takeoffTime).format('HH:mm')).fontSize(16)
          Text(item.departureAirport)
            .fontSize(10)
            .fontColor('#99000000')
            .maxLines(1)
            .constraintSize({ maxWidth: 70 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }

        Column({ space: 4 }) {
          Text(getFlyDuration(item))
            .fontSize(8)
            .fontColor('#466DFA')
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
            if (isNextDay(item)) {
              Span('次日').fontSize(8).fontColor('#99000000')
            }
            Span(new DayFormat(item.landingTime).format('HH:mm')).fontSize(16)
          }

          Text(item.destinationAirport)
            .fontSize(10)
            .fontColor('#99000000')
            .maxLines(1)
            .constraintSize({ maxWidth: 70 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .justifyContent(FlexAlign.SpaceAround)

      Row() {
      }.width(Constants.FULL_PERCENT_WIDTH).height(1).border({
        width: { bottom: 1 },
        color: { bottom: $r('sys.color.ohos_id_color_button_divider') },
        style: { bottom: BorderStyle.Dotted },
      })

      Row() {
        Text('经济舱' + item.lowestDiscount + '折')
          .fontSize(10).fontColor('#99000000')

        Text(Constants.RMB + item.lowestPrice)
          .fontSize(16).fontWeight(FontWeight.Medium)
          .fontColor('#D94838')
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .borderRadius(16)
    .padding(12)
    .backgroundColor($r('sys.color.white'))
    .onClick(() => {
      AppRouter.push({
        url: 'FlightDetailPage',
        param: item
      })
    })
  }

  @Builder
  EmptyBuilder() {
    Column() {
      Image($r('app.media.ic_empty')).width(100).height(60)

      Text('抱歉，查询无结果').fontSize(13).fontColor('#ff6b6b6b')
        .margin({ top: 20 })

      Button('重新搜索', { type: ButtonType.Normal, stateEffect: true })
        .borderRadius(4)
        .fontSize(13)
        .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
        .margin({ top: 10 })
        .onClick(() => {
          this.getFlightList()
        })
    }
    .layoutWeight(1)
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.white'))
  }

  @Builder
  TipSheetBuilder() {
    Row() {
      Text($r('app.string.booking_flight_tip')).fontSize(13)
        .fontWeight(400)
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .padding({left: 16, right:16})
  }

  @Builder
  ListTopView() {
    Column({ space: 12 }) {
      // 提示
      Row() {
        BaseTip({
          text: $r('app.string.booking_flight_tip'),
          onClickTip: () => {
            this.isShowTipMode = !this.isShowTipMode
          }
        });
      }
      .padding({
        left: 10,
        right: 10,
        top: 6,
        bottom: 6,
      })
      .backgroundColor('rgba(0,0,0,0.05)')
      .borderRadius(4)
      .width(Constants.FULL_PERCENT_WIDTH)
      .bindSheet($$this.isShowTipMode, this.TipSheetBuilder(), {
        height: 160,
        blurStyle: BlurStyle.COMPONENT_THICK,
        preferType: SheetType.BOTTOM,
        title: {
          title: $r('app.string.booking_tip_title')
        },
      })

      Row({ space: 8 }) {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Row() {
            Text('时间')
              .fontColor(this.sortBy === SortBy.TIME ? Color.White : $r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Medium)
            Image(this.sortBy === SortBy.TIME ? this.getSortImg() : $r('app.media.ic_sort_default'))
              .width(14)
              .height(22)
          }.alignItems(VerticalAlign.Center)
        }
        .borderRadius(8).backgroundColor(this.sortBy === SortBy.TIME ? '#466DFA' : Color.White)
        .padding(8)
        .onClick(() => {
          // 如果点击时间排序之前是价格排序，点击之后会按照起飞时间升序排序
          if (this.sortBy === SortBy.PRICE) {
            this.sortBy = SortBy.TIME
            this.sortType = 'asc'
          } else {
            if (this.sortType === 'asc') {
              this.sortType = 'desc' // 降序
            } else {
              this.sortType = 'asc' // 升序
            }
          }

          this.sortFlightList()
        })

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Row() {
            Text('价格')
              .fontColor(this.sortBy === SortBy.PRICE ? Color.White : $r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Medium)
            Image(this.sortBy === SortBy.PRICE ? this.getSortImg() : $r('app.media.ic_sort_default'))
              .width(14)
              .height(22)
          }.alignItems(VerticalAlign.Center)
        }
        .borderRadius(8).backgroundColor(this.sortBy === SortBy.PRICE ? '#466DFA' : Color.White)
        .padding(8)
        .onClick(() => {
          // 如果点击价格排序之前是时间排序，点击之后会按照价格升序排序
          if (this.sortBy === SortBy.TIME) {
            this.sortBy = SortBy.PRICE
            this.sortType = 'asc'
          } else {
            if (this.sortType === 'asc') {
              this.sortType = 'desc' // 降序
            } else {
              this.sortType = 'asc' // 升序
            }
          }

          this.sortFlightList()
        })
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .justifyContent(FlexAlign.Start)
      .padding({ left: 8 })
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#fff5f3f3')
  }
}