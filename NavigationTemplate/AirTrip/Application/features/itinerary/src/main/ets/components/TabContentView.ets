import { CommonDataSource, DayFormat, Trip } from 'common'
import { ItineraryTabItem } from '../model/ItineraryPageModel'

@ComponentV2
export struct TabContentView {
  @Local isRefreshing: boolean = false
  @Local ratio: number = 1
  @Local maxRefreshingHeight: number = 200.0
  @Param allList: Trip[] = []
  @Param tabItem: ItineraryTabItem = new ItineraryTabItem('', 0, '')
  private listDataSource = new CommonDataSource<Trip>()
  @Event refreshList: () => void = () => {}
  @Event onClickItem: (data: Trip) => void = (data: Trip) => {}
  @Local totalCount: number = -1

  @Monitor('allList')
  onAllListChange(monitor: IMonitor) {
    // 初始化列表数据
    this.initList()
  }

  aboutToAppear(): void {
    // 初始化列表数据
    this.initList()
  }

  initList() {
    let list: Trip[] = this.allList.filter((item: Trip) => item.status === this.tabItem.status)
    this.listDataSource.setData(list)
    this.totalCount = this.listDataSource.totalCount()
    this.isRefreshing = false
  }

  // 判断是否是次日
  isNextDay(item: Trip): boolean {
    const depDate = new Date(item.planTakeoffTime).toDateString();
    const arrDate = new Date(item.planLandingTime).toDateString();
    return depDate !== arrDate;
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
  RefreshContent() {
    if (this.totalCount === 0) {
      this.emptyBuilder()
    } else {
      this.ListContent()
    }
  }

  @Builder
  ListContent() {
    List({ space: 24 }) {
      LazyForEach(this.listDataSource, (item: Trip, index: number) => {
        ListItem() {
          this.TripItem(item)
        }
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24 })
    .divider({strokeWidth: 0.5, color: $r('sys.color.ohos_id_color_button_divider') })
  }

  @Builder
  TripItem(data: Trip) {
    Column({space: 14}) {
      Row() {
        Text() {
          Span(data.airlineName + ' ')
          Span(data.flightNo).fontColor('#99000000')
          Span(data.aircraftType).fontColor('#99000000')
        }
        .fontSize(10)
        .fontWeight(FontWeight.Regular)

        Text(new DayFormat(new Date(data.planTakeoffTime)).format('YYYY年MM月DD日'))
          .fontColor('#99000000')
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Row() {
          Column() {
            Circle()
              .width(6)
              .height(6)
              .fillOpacity(0)
              .strokeWidth(2)
              .stroke('#64BB5C')
              .offset({ x: -3, y: -7 })

            Circle()
              .width(6)
              .height(6)
              .fillOpacity(0)
              .strokeWidth(2)
              .stroke('#ED6F21')
              .offset({ x: -3, y: 8 })
          }
          .alignSelf(ItemAlign.Stretch)
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({
            left: 4,
            top: 12,
            right: 4,
            bottom: 14
          })
          .border({
            width: { left: 1 },
            color: { left: $r('sys.color.ohos_id_color_text_tertiary') },
            style: { left: BorderStyle.Dashed }
          })

          Column({space: 14}) {
            this.TripInfoView(data.planTakeoffTime.split(' ')[1], data.departureAirport)
            this.TripInfoView(data.planLandingTime.split(' ')[1], data.destinationAirport, this.isNextDay(data))
          }
          .alignItems(HorizontalAlign.Start)
        }
        Row() {
          Text(data.status === '1' ? '待出行' : '已使用')
            .fontSize(12)
            .fontWeight(FontWeight.Regular)
            .fontColor(data.status === '1' ? '#466DFA' : '#99000000')
          Image($r('app.media.ic_right_arrow')).width(14).height(14).fillColor($r('sys.color.ohos_id_color_text_tertiary'))
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .onClick(() => {
      this.onClickItem && this.onClickItem(data)
    })
  }

  @Builder
  TripInfoView(time: string, airport: string, isNext: boolean = false) {
    Row({space: 30}) {
      Row({space: 2}) {
        Text(time)
          .fontSize(12)
          .fontWeight(FontWeight.Regular)

        Text('次日').visibility(isNext ? Visibility.Visible : Visibility.Hidden)
          .fontSize(8).fontWeight(FontWeight.Regular).fontColor('#99000000')
      }
      Text(airport)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
    }
  }

  @Builder
  customRefreshComponent() {
    Row() {
    }
    .height(32)
    .width('100%')
  }

  build() {
    Column() {
      Refresh({ refreshing: $$this.isRefreshing, builder: this.customRefreshComponent }) {
        Scroll() {
          this.RefreshContent()
        }
        .width('100%')
        .height('100%')
      }
      .onRefreshing(() => {
        this.refreshList()
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
}