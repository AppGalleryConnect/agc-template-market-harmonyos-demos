import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { BaseFollowWatchPage } from '../components/BaseFollowWatchPage';
import { WatchPageViewModel } from '../viewmodels/WatchPageVM';

@Builder
export function WatchPageBuilder() {
  WatchPage()
}

@ComponentV2
struct WatchPage {
  @Local vm: WatchPageViewModel = new WatchPageViewModel();

  aboutToAppear(): void {
    this.vm.init();
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: this.vm.title,
          onBack: () => {
            this.vm.customBack();
          },
        })
        BaseFollowWatchPage({
          vm: this.vm,
          loading: this.vm.loadingModel.loading,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
      this.vm.customBack();
      return true;
    })
  }
}