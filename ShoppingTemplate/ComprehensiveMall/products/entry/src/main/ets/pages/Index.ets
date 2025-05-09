import { router } from '@common/router';
import { Style } from '@common/const';
import { LoadingStatus } from '@common/customtypes';
import { iData } from '@common/data';
import { TabSwiper } from '@components/tabswiper';

import uiObserver from '@ohos.arkui.observer';

import { IndexLogic } from '../logic/IndexLogic';

@Entry
@ComponentV2
struct Index {

  private readonly logic: IndexLogic = new IndexLogic();

  aboutToAppear(): void {
    iData.global.isNavPathStackEmpty = router.size() === 0;
    uiObserver.on('navDestinationUpdate', (_: NavDestinationInfo) => {
      iData.global.isNavPathStackEmpty = router.size() === 0;
      // if (info.index === 0 &&
      //     info.state === uiObserver.NavDestinationState.ON_DISAPPEAR &&
      //     router.size() === 0) {
      //   iData.global.isNavPathStackEmpty = true;
      // } else {
      //   iData.global.isNavPathStackEmpty = false;
      // }
    });
  }

  aboutToDisappear(): void {
    uiObserver.off('navDestinationUpdate');
  }

  build(): void {
    if (this.logic.loadingStatus === LoadingStatus.SUCCESS) {
      Navigation(router) {
        TabSwiper({
          viewData: this.logic.tabSwiperViewData,
          disableSwipe: true,
          tabLayoutMode: 'SpaceAround',
          tabsContainerMinHeight: Style.BOTTOM_NAV_HEIGHT,
          trackEdgeEffectMode: EdgeEffect.None,
          barPosition: BarPosition.End,
          barOverlap: true,
          barBackgroundColor: this.logic.barBackgroundColor,
          barExpandSafeArea: true,
          barBackgroundBlurStyle: this.logic.barBackgroundBlurStyle,
          barBackgroundBlurStyleOptions: Style.BOTTOM_NAV_BLUR_STYLE_OPTION,
          swiperInitialIndex: this.logic.initialIndex,
          swiperBackgroundColor: '#FFF1F3F5',
          swiperExpandSafeArea: true,
          onChange: this.logic.onTabSwiperChange
        })
      }
      .width('100%')
      .height('100%')
      .titleMode(NavigationTitleMode.Mini)
      .hideTitleBar(true, false)
      .hideBackButton(true)
    }
  }
}
