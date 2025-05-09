import { AppRouter, Constants } from 'common'
import { BaseTitle } from 'components';
import { FlightInfo } from '../model/FlightPageModel';

@Builder
export function flightNumListPageBuilder() {
  FlightNumListPage()
}

@ComponentV2
export struct FlightNumListPage {
  @Local flightNumList: FlightInfo[] = []

  build() {
    NavDestination() {
      Column() {
        BaseTitle({
          title: '选择航班',
          showBackBtn: true,
          bgColor: $r('sys.color.white'),
          onBack: () => {
            AppRouter.pop()
          },
        })

        List() {
          ForEach(this.flightNumList, (item: FlightInfo) =>{
            ListItem() {
              Row() {
                Text(item.flightNo)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .height(50)
              .onClick(() => {
                AppRouter.push({
                  url: 'FlightTrackInfoPage',
                  param: item.flightNo
                })
              })
            }
          })
        }
        .width(Constants.FULL_PERCENT_WIDTH)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .padding({ left:16, right: 16 })
        .divider({ strokeWidth: 0.5, color: $r('sys.color.ohos_id_color_button_divider') })
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.gray_01'))
    .onReady((cxt) => {
      this.flightNumList = cxt.pathInfo.param as FlightInfo[]
    })
  }
}