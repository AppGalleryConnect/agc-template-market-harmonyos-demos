import { CommonHeader } from 'componentlib';
import { LocationPageVM } from './LocationPageVM';
import { map, MapComponent } from '@kit.MapKit';
import { RouterModule } from 'commonlib';

@Builder
export function locationPageBuilder() {
  LocationPage();
}

@ComponentV2
export struct LocationPage {
  vm: LocationPageVM = LocationPageVM.instance;
  // 自定义信息窗BuilderParam
  @BuilderParam customInfoWindow: ($$: map.MarkerDelegate) => void = this.customInfoWindowBuilder;

  build() {
    NavDestination() {
      CommonHeader({
        title: '酒店位置',
      });
      Stack({
        alignContent: Alignment.BottomStart,
      }) {
        MapComponent({
          mapOptions: this.vm.mapOptions,
          mapCallback: this.vm.callback,
          customInfoWindow: this.customInfoWindow,
        }).width('100%').height('100%');
        this.guideButtonBuilder();
      };
    }
    .hideTitleBar(true)
    .onReady(() => {
      if (!this.vm.mapController) {
        this.vm.initController();
      }
    })
    .onShown(async () => {
      if (this.vm.mapController !== undefined) {
        this.vm.mapController.show();
      } else {

      }
    })
    .onBackPressed(() => {
      RouterModule.pop();
      return true;
    })
    .onHidden(() => {
      // 将地图切换到后台
      if (this.vm.mapController !== undefined) {
        this.vm.mapController.hide();
      }
    });
  }

  @Builder
  guideButtonBuilder() {
    Row() {
      Image($r('app.media.ic_guide'))
        .width(24)
        .margin({
          right: $r('app.string.margin_s'),
        });
      Text('导航')
        .fontSize($r('app.string.font_size_28'));
    }
    .alignItems(VerticalAlign.Center)
    .width('30%')
    .padding({
      left: $r('app.string.padding_m'),
      right: $r('app.string.padding_m'),
      top: $r('app.string.padding_s'),
      bottom: $r('app.string.padding_s'),
    })
    .margin({
      left: $r('app.string.margin_m'),
      bottom: 60,
    })
    .borderRadius(50)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.system_color_background_white'))
    .onClick(() => {
      this.vm.handleClickGuide();
    });
  }

  @Builder
  customInfoWindowBuilder($$: map.MarkerDelegate) {
    Row() {
      if ($$.marker) {
        Text($$.marker.getTitle())
          .fontSize($r('app.string.font_size_28'))
          .fontColor($r('app.color.font_color_level1_invert'));
      }
    }
    .padding({
      left: $r('app.string.padding_s'),
      right: $r('app.string.padding_s'),
      top: $r('app.string.padding_xs'),
      bottom: $r('app.string.padding_xs'),
    })
    .margin({right:$r('app.string.margin_m')})
    .backgroundColor($r('app.color.system_color_focus'))
    .borderRadius($r('app.string.border_radius_8'));

  }
}