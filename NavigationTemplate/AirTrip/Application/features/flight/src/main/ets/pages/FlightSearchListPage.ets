import { AppRouter, Constants,
  DayFormat,
  getDayLabel,
  LoadingStatus,
} from 'common';
import { FlightInfo, FlightListResult } from '../model/FlightPageModel';
import { FlightApi } from '../api/FlightApi';
import { BaseTitle, GlobalDialog } from 'components';

@Builder
export function flightSearchListPageBuilder() {
  FlightSearchListPage()
}

@ComponentV2
export struct FlightSearchListPage {
  // 当前月视图或周视图中选中的日期
  @Local departureDate: Date = new Date();
  @Local departureCity: string = '';
  @Local destinationCity: string = '';
  @Local loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @Local isRefreshing: boolean = false;
  @Local flightList: FlightInfo[] = [];
  @Local isPreDisabled: boolean = false;
  @Local isNextDisabled: boolean = false;

  @Monitor('loadingStatus')
  onLoadingStatusChange(monitor: IMonitor) {
    if (monitor.value()?.now === LoadingStatus.LOADING) {
      GlobalDialog.showLoadingDialog();
    } else {
      GlobalDialog.close();
    }
  }

  getFlightList() {
    this.loadingStatus = LoadingStatus.LOADING;
    // 实际的时间
    let departureDate = new DayFormat(this.departureDate).format('YYYY/MM/DD');
    let params: Record<string, string> = {
      'departureCity': this.departureCity,
      'destinationCity': this.destinationCity,
      'departureDate': '2025/04/09', // 当前只有这个时间能查到数据
    };
    FlightApi.getFlightSearchList(params).then((res) => {
      let result = res.result as FlightListResult;
      if (result.ret.code === 0) {
        // mock数据
        this.flightList = (result.result as FlightInfo[] || []).map((flight: FlightInfo) => {
          let start = flight.takeoffTime.split(' ');
          let end = flight.landingTime.split(' ');
          flight.takeoffTime = departureDate + ' ' + start[1];

          if (end[0] === start[0]) {
            flight.landingTime = departureDate + ' ' + end[1];
          } else {
            let pre = this.departureDate.getTime() + 24 * 60 * 60 * 1000;
            flight.landingTime = new DayFormat(new Date(pre)).format('YYYY/MM/DD') + ' ' + end[1];
          }
          return flight;
        });
      }
      this.loadingStatus = this.flightList.length ? LoadingStatus.SUCCESS : LoadingStatus.EMPTY
      this.isRefreshing = false;
    }).catch(() => {
      this.loadingStatus = LoadingStatus.EMPTY;
      this.isRefreshing = false;
    });
  }

  getStatusLabel(data: FlightInfo) {
    let departureDateTime = new Date(data.takeoffTime).getTime();
    let nowTime = new Date().getTime();
    let diff = departureDateTime - nowTime;
    return diff >= 0 ? '计划' : '到达';
  }

  getNextDateText(data: FlightInfo): string {
    let takeoffTime = data.takeoffTime.split(' ')[0];
    let landTime = data.landingTime.split(' ')[0];
    return takeoffTime === landTime ? '' : '次日';
  }

  @Builder
  CustomTitleBuilder() {
    Row({ space: 6 }) {
      Text(this.departureCity);
      Image($r('app.media.ic_goto')).width(14).height(14);
      Text(this.destinationCity);
    };
  }

  @Builder
  DateSelectView() {
    Row() {
      Text('前一天').fontWeight(400)
        .fontColor(this.isPreDisabled ? $r('sys.color.ohos_id_color_text_tertiary') :
        $r('sys.color.ohos_id_color_text_primary'))
        .onClick(() => {
          if (this.isPreDisabled) {
            return;
          }
          this.isNextDisabled = false;
          let today = new Date();
          let y = today.getFullYear();
          let startDate = new Date(`${y}-01-01`).getTime();
          let departureDate = new DayFormat(this.departureDate).format('YYYY-MM-DD');
          let dateTime = new Date(departureDate).getTime() - 24 * 60 * 60 * 1000;
          if (dateTime === startDate) {
            this.isPreDisabled = true;
          }
          this.departureDate = new Date(dateTime);
          this.getFlightList();
        });

      Text() {
        Span(new DayFormat(this.departureDate).format('MM月DD日'));
        Span(' ');
        Span(getDayLabel(this.departureDate));
      }.fontWeight(400);

      Text('后一天').fontWeight(400)
        .fontColor(this.isNextDisabled ? $r('sys.color.ohos_id_color_text_tertiary') :
        $r('sys.color.ohos_id_color_text_primary'))
        .onClick(() => {
          if (this.isNextDisabled) {
            return;
          }
          this.isPreDisabled = false;
          let today = new Date();
          let y = today.getFullYear();
          let endY = y + 1;
          let endDate = new Date(`${endY}-12-31`).getTime();
          let departureDate = new DayFormat(this.departureDate).format('YYYY-MM-DD');
          let dateTime = new Date(departureDate).getTime() + 24 * 60 * 60 * 1000;
          if (dateTime === endDate) {
            this.isNextDisabled = true;
          }
          this.departureDate = new Date(dateTime);
          this.getFlightList();
        });
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.white'))
    .padding({ left: 26, right: 26, bottom: 16 });
  }

  build() {
    NavDestination() {
      BaseTitle({
        customTitle: () => {
          this.CustomTitleBuilder();
        },
        showBackBtn: true,
        onBack: () => {
          AppRouter.pop();
        },
      });

      this.DateSelectView();

      if (this.loadingStatus === LoadingStatus.FAILED || this.loadingStatus === LoadingStatus.EMPTY) {
        this.emptyBuilder();
      }
      if (this.loadingStatus === LoadingStatus.SUCCESS) {
        this.ListContent();
      }
    }
    .hideTitleBar(true)
    .onReady((cxt) => {
      let params = cxt.pathInfo.param as Record<string, string | Date>;
      this.departureCity = params.departureCity as string;
      this.destinationCity = params.destinationCity as string;
      this.departureDate = params.departureDate as Date;
    })
    .onWillShow(() => {
      this.getFlightList();
    });
  }

  @Builder
  ListContent() {
    Refresh({ refreshing: $$this.isRefreshing }) {
      List({ space: 10 }) {
        // 用来占位，布局使用
        ListItem() {
        };

        // 列表数据
        ForEach(this.flightList, (item: FlightInfo) => {
          ListItem() {
            this.FlightItemView(item);
          };
        });
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .height(Constants.FULL_PERCENT_HEIGHT)
      .padding({ left: 14, right: 14 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None);
    }
    .onRefreshing(() => {
      this.getFlightList();
    })
    .pullToRefresh(true)
    .width(Constants.FULL_PERCENT_WIDTH)
    .layoutWeight(1)
    .backgroundColor('#fff5f3f3');
  }

  @Builder
  FlightItemView(item: FlightInfo) {
    Row() {
      Row({ space: 10 }) {
        Image($r('app.media.ic_air_logo'))
          .width(24).height(24)
          .margin({ top: 10 });

        Column({ space: 8 }) {
          Row({ space: 12 }) {
            Column({ space: 4 }) {
              Text(new DayFormat(item.takeoffTime).format('HH:mm'))
                .fontSize(18).fontWeight(FontWeight.Bold);
              Text(item.departureAirport)
                .fontSize(13).fontWeight(400);
            }
            .alignItems(HorizontalAlign.Start);

            Image($r('app.media.ic_flight_tip')).width(50).height(12);

            Column({ space: 4 }) {
              Row({ space: 4 }) {
                Text(new DayFormat(item.landingTime).format('HH:mm'))
                  .fontSize(18).fontWeight(FontWeight.Bold);
                Text(this.getNextDateText(item))
                  .fontSize(10).fontColor($r('sys.color.ohos_id_color_text_tertiary'));
              };

              Text(item.destinationAirport)
                .fontSize(13).fontWeight(400);
            }
            .alignItems(HorizontalAlign.Start);
          };

          Row({ space: 4 }) {
            Text(item.airlineName)
              .fontSize(13)
              .fontWeight(400)
              .fontColor($r('sys.color.ohos_id_color_text_tertiary'));
            Text(item.flightNo)
              .fontSize(13)
              .fontWeight(400)
              .fontColor($r('sys.color.ohos_id_color_text_tertiary'));
          };
        }
        .alignItems(HorizontalAlign.Start);
      }
      .alignItems(VerticalAlign.Top);

      Text(this.getStatusLabel(item))
        .fontSize(18)
        .fontColor($r('sys.color.font_emphasize'));
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(6)
    .padding(12)
    .backgroundColor($r('sys.color.white'))
    .onClick(() => {
      AppRouter.push({
        url: 'FlightTrackInfoPage',
        param: item.flightNo
      })
    });
  }

  @Builder
  emptyBuilder() {
    Column() {
      Image($r('app.media.ic_empty')).width(100).height(60);

      Text('抱歉，查询无结果').fontSize(13).fontColor('#ff6b6b6b')
        .margin({ top: 20 });

      Button('重新搜索', { type: ButtonType.Normal, stateEffect: true })
        .borderRadius(4)
        .fontSize(13)
        .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
        .margin({ top: 10 })
        .onClick(() => {
          this.getFlightList();
        });
    }
    .layoutWeight(1)
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.white'));
  }
}