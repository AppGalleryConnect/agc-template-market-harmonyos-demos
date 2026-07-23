import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { BaseMarkLikePage } from '../components/BaseMarkLikePage';
import { LikeViewModel } from '../viewmodels/LikeVM';

@Builder
export function LikePageBuilder() {
  LikePage()
}

@ComponentV2
struct LikePage {
  @Local vm: LikeViewModel = new LikeViewModel();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我的点赞',
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