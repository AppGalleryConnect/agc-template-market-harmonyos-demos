
import { MapPageVM } from '../viewModels/MapPageVM';
import { map, MapComponent } from '@kit.MapKit';
import { RouterModule } from 'commonlib';

@Builder
export function MapPageBuilder() {
  MapPage();
}

@ComponentV2
export struct MapPage {
  vm: MapPageVM = MapPageVM.instance;
  // 自定义信息窗BuilderParam
  @BuilderParam customInfoWindow: ($$: map.MarkerDelegate) => void = this.customInfoWindowBuilder;

  build() {
    NavDestination() {
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
    .title('场馆地图')
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
          right: 10,
        });
      Text('导航')
        .fontSize(20);
    }
    .alignItems(VerticalAlign.Center)
    .width('30%')
    .padding({
      left: 20,
      right: 20,
      top: 10,
      bottom: 10,
    })
    .margin({
      left: 20,
      bottom: 60,
    })
    .borderRadius(50)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .onClick(() => {
      this.vm.handleClickGuide();
    });
  }

  @Builder
  customInfoWindowBuilder($$: map.MarkerDelegate) {
    Row() {
      if ($$.marker) {
        Text($$.marker.getTitle())
          .fontSize(20)
          .fontColor(Color.White);
      }
    }
    .padding({
      left: 10,
      right: 10,
      top: 4,
      bottom: 4,
    })
    .margin({right:20})
    .backgroundColor($r('app.color.system_color_focus'))
    .borderRadius(8);

  }
}