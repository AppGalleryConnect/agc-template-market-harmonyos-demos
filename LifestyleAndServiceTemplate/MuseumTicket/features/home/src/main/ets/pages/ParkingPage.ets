import { CommonConstants } from 'commonlib';
import { HomePageVM } from '../viewModels/HomePageVM';
import { ParkTextResp } from 'network';

@Builder
export function ParkingPageBuilder() {
  ParkingPage();
}


@ComponentV2
struct ParkingPage {
  @Local vm: HomePageVM = HomePageVM.instance;

  aboutToAppear(): void {
    this.vm.getParkingText();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          ForEach(this.vm.parkingText, (item: ParkTextResp) => {
            Text() {
              Span(item.title).fontWeight(600);
              Span(item.content);
            }.fontColor(CommonConstants.FONT_COLOR_BLACK).lineHeight(22);
          }, (item: ParkTextResp) => item.title);
        }
        .padding(20)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(CommonConstants.BG_COLOR_WHITE)
        .constraintSize({ minHeight: '100%' });

      }
      .width('100%')
      .backgroundColor(CommonConstants.BG_COLOR_GRAY)
      .height('100%')
      .padding({ top: 10 })
      .scrollBar(BarState.Off)
      .align(Alignment.Top);
    }.title('停车缴费');

  }
}