import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { BaseFollowWatchPage } from '../components/BaseFollowWatchPage';
import { FollowerPageViewModel } from '../viewmodels/FollowerPageVM';

@Builder
export function FollowerPageBuilder() {
  FollowerPage()
}

@ComponentV2
struct FollowerPage {
  @Local vm: FollowerPageViewModel = new FollowerPageViewModel();

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