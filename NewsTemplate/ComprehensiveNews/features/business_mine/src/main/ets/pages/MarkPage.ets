import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { BaseMarkLikePage } from '../components/BaseMarkLikePage';
import { MarkViewModel } from '../viewmodels/MarkVM';

@Builder
export function MarkPageBuilder() {
  MarkPage()
}

@ComponentV2
struct MarkPage {
  @Local vm: MarkViewModel = new MarkViewModel();

  aboutToAppear(): void {
    this.vm.queryList();
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我的收藏',
        })
        BaseMarkLikePage({
          vm: this.vm,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .onShown(() => {
      this.vm.queryList(false);
    })
  }
}