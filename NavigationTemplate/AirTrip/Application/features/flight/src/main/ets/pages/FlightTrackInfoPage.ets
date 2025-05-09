import { AppRouter, Constants, LoadingStatus } from 'common';
import { BaseTitle, GlobalDialog } from 'components';
import { FlightApi } from '../api/FlightApi';
import { FlightInfo, FlightListResult } from '../model/FlightPageModel';

@Builder
export function flightTrackInfoPageBuilder() {
  FlightTrackInfoPage()
}

@ComponentV2
export struct FlightTrackInfoPage {
  @Local loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @Local flightNo: string = '';
  // 行程详情
  @Local flightDetail: FlightInfo = new FlightInfo();

  getFlightTrackInfo() {
    GlobalDialog.showLoadingDialog();
    FlightApi.getFlightDetail(this.flightNo).then((res) => {
      let result = res.result as FlightListResult;
      if (result.ret.code === 0) {
        if (result.result?.[0]) {
          this.flightDetail = result.result[0]
        }
      }
      this.loadingStatus = LoadingStatus.SUCCESS;
    }).finally(() => {
      GlobalDialog.close()
    })
  }

  build() {
    NavDestination() {
      Column() {
        BaseTitle({
          title: '航班信息',
          showBackBtn: true,
          bgColor: $r('sys.color.white'),
          onBack: () => {
            AppRouter.pop()
          },
        })

        if (this.loadingStatus === LoadingStatus.SUCCESS) {
          Column({ space: 12 }) {
            Column({ space: 12 }) {
              if (this.flightDetail.flightNo) {
                Row({ space: 8 }) {
                  Image($r('app.media.ic_air_logo')).width(24).height(24)
                  Text(this.flightDetail.airlineName).fontWeight(400).fontSize(13)
                  Text(this.flightDetail.flightNo).fontWeight(400).fontSize(13)
                }
              }

              Row() {
                Text(this.flightDetail.departureAirport)
                  .fontWeight(FontWeight.Bold).fontSize(16)
                Text(this.flightDetail.takeoffTime).fontWeight(400).fontSize(13)
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .justifyContent(FlexAlign.SpaceBetween)

              Row() {
                Column({ space: 8 }) {
                  Text('实际起飞')
                    .fontWeight(400)
                    .fontSize(13)
                    .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                  Text(this.flightDetail.takeoffTime.split(' ')[1] || '--')
                    .fontWeight(FontWeight.Bold).fontSize(16)
                    .fontColor($r('sys.color.font_emphasize'))
                }

                Column({ space: 8 }) {
                  Text('值机柜台')
                    .fontWeight(400)
                    .fontSize(13)
                    .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                  Text(this.flightDetail.id ? 'J,K' : '--').fontWeight(FontWeight.Bold).fontSize(16)
                }

                Column({ space: 8 }) {
                  Text('登机口')
                    .fontWeight(400)
                    .fontSize(13)
                    .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                  Text(this.flightDetail.id ? 'C53' : '--').fontWeight(FontWeight.Bold).fontSize(16)
                }
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .justifyContent(FlexAlign.SpaceAround)

              Row() {
                Text(this.flightDetail.destinationAirport)
                  .fontWeight(FontWeight.Bold).fontSize(16)
                Text(this.flightDetail.landingTime).fontWeight(400).fontSize(13)
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .justifyContent(FlexAlign.SpaceBetween)

              Row() {
                Column({ space: 8 }) {
                  Text('实际到达')
                    .fontWeight(400)
                    .fontSize(13)
                    .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                  Text(this.flightDetail.landingTime.split(' ')[1] || '--')
                    .fontWeight(FontWeight.Bold).fontSize(16)
                    .fontColor($r('sys.color.font_emphasize'))
                }
                Column({ space: 8 }) {
                  Text('行李转盘')
                    .fontWeight(400)
                    .fontSize(13)
                    .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                  Text(this.flightDetail.id ? '22' : '--')
                    .fontWeight(FontWeight.Bold).fontSize(16)
                }

                Column({ space: 8 }) {
                  Text('出口')
                    .fontWeight(400)
                    .fontSize(13)
                    .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                  Text('--')
                    .fontWeight(FontWeight.Bold).fontSize(16)
                }
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .justifyContent(FlexAlign.SpaceAround)

            }
            .width(Constants.FULL_PERCENT_WIDTH)
            .alignItems(HorizontalAlign.Start)
            .padding(14)
            .backgroundColor($r('sys.color.white'))
            .borderRadius(16)
          }
          .width(Constants.FULL_PERCENT_WIDTH)
          .padding({ left: 16, right: 16, top: 24 })
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.gray_01'))
    .onReady((cxt) => {
      if (cxt.pathInfo.param) {
        if (typeof cxt.pathInfo.param === 'string') {
          this.flightNo = cxt.pathInfo.param
          this.getFlightTrackInfo()
        } else {
          this.flightDetail = cxt.pathInfo.param as FlightInfo
          this.loadingStatus = LoadingStatus.SUCCESS;
        }
      }
    })
  }
}