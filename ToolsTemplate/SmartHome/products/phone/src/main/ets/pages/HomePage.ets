import { Constants } from 'utils';
import { AddEntryView } from 'device_add';
import { NotifyEntryView } from 'device_mng';
import { HomeViewModel } from '../viewmodel/HomeViewModel';
import { DevicesCardsView } from '../view/DevicesCardsView';
import { PersonalTitleView } from 'device_service';

@ComponentV2
export struct HomePage {
  @Param pathStack: NavPathStack = new NavPathStack();
  homeViewModel: HomeViewModel = new HomeViewModel();
  marginTop = 16;
  private bannerImages: ResourceStr[] = [$r('app.media.banner1'), $r('app.media.banner2'), $r('app.media.banner3')]

  @Local totalHeight: number = 0;
  @Local titleAndMenuHeight: number = 0;
  @Local myDeviceTextHeight: number = 0;

  @Builder
  BuildTitle() {
    Row() {
      PersonalTitleView();
    };
  }

  @Builder
  BuildTitleAndMenu() {
    Row() {
      this.BuildTitle();
      Blank();
      this.BuildMenu();
    }
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.titleAndMenuHeight = Number(newValue.height)
    })
    .alignItems(VerticalAlign.Bottom)
    .width('100%');
  }

  @Builder
  BuildSwiper() {
    Swiper() {
      ForEach(this.bannerImages, (item: ResourceStr) => {
        Image(item)
      }, (item: ResourceStr) => {
        return JSON.stringify(item)
      })
    }
    .width('100%')
    .height(150)
    .loop(true)
    .autoPlay(true)
    .interval(2000)
    .borderRadius(16)
  }

  @Builder
  BuildMenu() {
    Row() {
      NotifyEntryView({ pathStack: this.pathStack, px: 32 });
      AddEntryView({ pathStack: this.pathStack, px: 32 })
        .margin({ left: 18 });
    };
  }

  @Builder
  BuildBackground() {
    Column() {
      Image($r('app.media.home_bg'))
        .size({ width: '100%', height: '20%' })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
    }
    .height('100%')
    .backgroundColor('#F1F3F5');
  }

  @Builder
  BuildForeground() {
    Column() {
      Column({ space: 20 }) {
        this.BuildTitleAndMenu();
        this.BuildSwiper();
        DevicesCardsView({ pathStack: this.pathStack })
          .height(420)
          .width('100%')
      }
      .width('90%')
      .margin({ top: Constants.PAGE_MARGIN_TOP });
    }
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.totalHeight = Number(newValue.height)
    })
  }

  build() {
    Navigation(this.pathStack) {
      Scroll(){
        Stack() {
          this.BuildBackground();
          this.BuildForeground();
        };
      }
      .scrollBar(BarState.Off)
    }
    .hideTitleBar(true);
  }
}