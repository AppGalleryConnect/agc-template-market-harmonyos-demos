import { CommonHeader, StoreMap } from 'componentlib';
import { LocationVM } from '../viewmodels/LocationPageVM';

@Builder
export function locationPageBuilder() {
  LocationPage();
}


@ComponentV2
export struct LocationPage {
  vm: LocationVM = LocationVM.instance;

  build() {
    NavDestination() {
      CommonHeader({ title: '附近门店' });
      Stack({ alignContent: Alignment.Bottom }) {
        if (this.vm.storeInfo) {
          StoreMap({
            storeInfo: this.vm.storeInfo,
            showInfoWindow: false,
            mapHeight: '100%',
          });
        }
        this.storeInfoCardBuilder();
      }
      .backgroundColor(Color.Black)
      .width($r('app.string.width_percent_full'))
      .layoutWeight(1);
    }
    .hideTitleBar(true)
    .onReady(() => {
      this.vm.initStoreInfo();
    });
  }

  @Builder
  storeInfoCardBuilder() {
    if (this.vm.storeInfo) {
      Row() {
        Column() {
          Text(this.vm.storeInfo.shopName)
            .fontSize($r('app.string.font_size_18'))
            .fontColor($r('app.color.font_color_level1'))
            .fontWeight(FontWeight.Medium);
          Text(this.vm.storeInfo.address)
            .fontSize($r('app.string.font_size_12'))
            .fontColor($r('app.color.font_color_level2'));
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Image($r('app.media.ic_map_guide'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.vm.jumpToGuide();
          });

      }
      .backgroundColor($r('app.color.system_color_background_white'))
      .width($r('app.string.width_percent_full'))
      .padding($r('app.string.padding_xl'))
      .borderRadius({
        topLeft: $r('app.string.border_radius_16'),
        topRight: $r('app.string.border_radius_16'),
      });
    }

  }
}