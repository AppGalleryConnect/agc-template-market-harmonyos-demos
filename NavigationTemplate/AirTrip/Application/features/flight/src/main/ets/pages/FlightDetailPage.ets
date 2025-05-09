import { AppRouter, BaseTabBarItem, Constants, DayFormat, formatMMDD,
  WebPageParams } from 'common'
import { BaseTip, BaseTitle } from 'components'
import { BaggageAndRefundSheet } from '../components/BaggageAndRefundSheet'
import { FlightInfo, FlightOrderInfo, FlightPageModel, FlightSpaceInfo } from '../model/FlightPageModel'
import { getFlyDuration, getWeekDay, isNextDay } from '../utils/FlightUtil'
import { FlightTicketListView } from './FlightTicketListView'

@Builder
export function flightDetailPageBuilder() {
  FlightDetailPage()
}

@ComponentV2
export struct FlightDetailPage {
  @Local flightInfo: FlightInfo = new FlightInfo()
  // 单程和往返的tab数据
  private tabBarList: BaseTabBarItem[] = [
    new BaseTabBarItem('ECONOMY_CLASS', '经济舱'),
    new BaseTabBarItem('FIRST_CLASS', '公务舱/头等舱'),
  ]
  @Local selectedBarIndex: number = 0
  private controller: TabsController = new TabsController()
  @Local flightSpaceList: FlightSpaceInfo[] = []
  @Local isShowTipMode: boolean = false
  // 行李改退签政策半模态
  @Local isShowMode: boolean = false
  
  getTicketList() {
    this.flightSpaceList = FlightPageModel.getFlightSpaceList(this.flightInfo)
  }

  getLowestPrice(tabBar: BaseTabBarItem): string {
    let classList = this.flightSpaceList.filter((item: FlightSpaceInfo) => item.spaceType === tabBar.type)
    return Constants.RMB + classList[0].spacePrice + '起'
  }

  build() {
    NavDestination() {
      Column() {
        BaseTitle({
          title: '舱位选择',
          showBackBtn: true,
          bgColor: $r('sys.color.white'),
          onBack: () => {
            AppRouter.pop()
          }
        })

        List() {
          ListItem() {
            this.ListTopView()
          }
          ListItem() {
            this.FlightInformation()
          }

          ListItem() {
            Row({space: 16}) {
              ForEach(this.tabBarList, (tabBar: BaseTabBarItem, index: number) => {
                Column() {
                  Text(tabBar.text).fontSize(16).fontWeight(FontWeight.Regular)
                  Text(this.getLowestPrice(tabBar))
                    .fontSize(12)
                    .fontWeight(FontWeight.Regular)
                }
                .width('calc((100% - 16vp) / 2)')
                .padding({top: 14, bottom: 14})
                .backgroundColor(this.selectedBarIndex === index ? '#CFD8F6' : Color.White)
                .border({
                  width: this.selectedBarIndex === index ? 1 : 0,
                  color: '#466DFA',
                  style: BorderStyle.Solid,
                  radius: 16
                })
                .onClick(() => {
                  this.selectedBarIndex = index
                })
              })
            }
            .width(Constants.FULL_PERCENT_WIDTH)
            .margin({top: 12})
            .justifyContent(FlexAlign.SpaceBetween)
          }

          ListItem() {
            Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.selectedBarIndex }) {
              ForEach(this.tabBarList, (tabBar: BaseTabBarItem, index: number) => {
                TabContent() {
                  FlightTicketListView({
                    type: tabBar.type,
                    listData: this.flightSpaceList.filter((item: FlightSpaceInfo) => item.spaceType === tabBar.type),
                    bookTicket: (data: FlightSpaceInfo) =>{
                      let params = {
                        flightInfo: this.flightInfo,
                        spaceInfo: data
                      } as FlightOrderInfo
                      AppRouter.push({
                        url: 'SubmitOrderPage',
                        param: params
                      })
                    },
                    viewBaggagePolicy: () => {
                      this.isShowMode = !this.isShowMode
                    }
                  })
                }
              })
            }
            .width('100%')
            .height('auto')
            .barHeight(0)
            .scrollable(false)
            .onChange((index: number) => {
              this.selectedBarIndex = index
            })
            .bindSheet($$this.isShowMode, this.SheetBuilder(), {
              height: '70%',
              blurStyle: BlurStyle.COMPONENT_THICK,
              preferType: SheetType.BOTTOM,
              title: {
                title: '改退签及行李额'
              },
            })
          }
          .margin({top: 10})
        }
        .width('100%')
        .layoutWeight(1)
        .padding({left: 16, right: 16})
        .scrollBar(BarState.Off)
      }
    }
    .hideTitleBar(true)
    .backgroundColor('#fff5f3f3')
    .onReady((cxt) => {
      let params: FlightInfo = cxt.pathInfo.param as FlightInfo
      this.flightInfo = params

      // 获取当前航班的舱位票价
      this.getTicketList()
    })
  }

  @Builder
  TipSheetBuilder() {
    Row() {
      Text($r('app.string.flight_space_tip')).fontSize(13)
        .fontWeight(400)
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .padding({left: 16, right:16})
  }

  // 行李改退签政策半模态
  @Builder
  SheetBuilder() {
    BaggageAndRefundSheet()
  }

  @Builder
  ListTopView() {
    Column({ space: 12 }) {
      // 提示
      Row() {
        BaseTip({
          text: $r('app.string.flight_space_tip'),
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
        height: 220,
        blurStyle: BlurStyle.COMPONENT_THICK,
        preferType: SheetType.BOTTOM,
        title: {
          title: $r('app.string.booking_tip_title')
        },
      })
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor('#fff5f3f3')
  }


  @Builder
  FlightInformation() {
    Column({ space: 14 }) {
      Row({ space: 6 }) {
        // 单程
        Text('单程')
          .fontSize(10)
          .fontColor($r('sys.color.white'))
          .padding({
            left: 6,
            right: 6,
            top: 3,
            bottom: 3
          })
          .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
          .borderRadius(16)

        // 出发日期
        Text(formatMMDD(this.flightInfo.takeoffTime)).fontSize(12)
        // 星期几
        Text(getWeekDay(this.flightInfo.takeoffTime)).fontSize(12)

        // 起降地
        Text() {
          Span(this.flightInfo.departureCity)
          Span(' - ')
          Span(this.flightInfo.destinationCity)
        }.fontSize(12)

        // 飞行时长
        Text(getFlyDuration(this.flightInfo)).fontSize(12).position({right: 0})
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .width(Constants.FULL_PERCENT_WIDTH)

      Row({space: 12}) {
        Column({ space: 24 }) {
          Text(new DayFormat(this.flightInfo.takeoffTime).format('HH:mm')).fontSize(16)

          Column() {
            if (isNextDay(this.flightInfo)) {
              Text('次日').fontSize(8).fontColor('#F9A01E')
            }
            Text(new DayFormat(this.flightInfo.landingTime).format('HH:mm')).fontSize(16)
          }
          .alignItems(HorizontalAlign.End)
        }

        Row(){}.width(4).height(70).backgroundColor('#F1F3F5').border({
          radius: {topLeft: 4, topRight: 4, bottomLeft: 4, bottomRight: 4}
        })

        Column({ space: 34 }) {
          Text(this.flightInfo.departureAirport).fontSize(16)
          Text(this.flightInfo.destinationAirport).fontSize(16)
        }
      }
      Row({space: 8}) {
        Text(this.flightInfo.airlineName + this.flightInfo.flightNo)
          .fontSize(10).fontColor('#99000000')
        Text(this.flightInfo.aircraftType)
          .fontSize(10).fontColor('#99000000')
        Text(this.flightInfo.mealType)
          .fontSize(10).fontColor('#99000000')
      }
    }
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.white'))
    .alignItems(HorizontalAlign.Start)
  }
}