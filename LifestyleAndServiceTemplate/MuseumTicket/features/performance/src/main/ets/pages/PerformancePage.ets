import { RecommendBar } from '../component/RecommendBar';
import { CommonConstants } from 'commonlib';

@Builder
export function PerformancePageBuilder() {
  PerformancePage();
}


@ComponentV2
export struct PerformancePage {
  build() {
    NavDestination() {
      Scroll() {
        RecommendBar();
      }
      .width('100%')
      .padding(10)
      .height(CommonConstants.FULL_HEIGHT)
      .backgroundColor(CommonConstants.BG_COLOR_GRAY)
      .align(Alignment.Top)
      .scrollBar(BarState.Off);
    }.title('特展购票');
  }
}