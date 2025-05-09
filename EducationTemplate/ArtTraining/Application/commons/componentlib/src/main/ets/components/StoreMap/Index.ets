import { map, MapComponent } from '@kit.MapKit';
import { StoreMapVM } from './StoreMapVM';
import { StoreInfo } from 'commonlib';

@ComponentV2
struct StoreMap {
  @Param mapWidth: Length = '100%';
  @Param mapHeight: Length = 200;
  @Param showInfoWindow: boolean = true;
  // @Param @Require storeInfo: StoreInfo;
  @Param storeInfo: StoreInfo | null = null;
  vm: StoreMapVM = StoreMapVM.instance;

  aboutToAppear() {
    if (this.storeInfo) {
      this.vm.initController(this.storeInfo);
    }
  }

  build() {
    Stack() {
      MapComponent({
        mapOptions: this.vm.mapOptions,
        mapCallback: this.vm.callback,
        // 自定义信息窗
        customInfoWindow: this.customInfoWindow.bind(this),
      })
        .width($r('app.string.width_percent_full'))
        .height($r('app.string.height_percent_full'));
    }
    .width(this.mapWidth)
    .height(this.mapHeight);
  }

  // 自定义信息窗BuilderParam
  @BuilderParam customInfoWindow: ($$: map.MarkerDelegate) => void = this.customInfoWindowBuilder;

  // 自定义信息窗Builder
  @Builder
  customInfoWindowBuilder($$: map.MarkerDelegate) {
    if ($$.marker && this.showInfoWindow) {
      Column() {
        Stack() {
          Image($r('app.media.ic_popover_bg'))
            .objectFit(ImageFit.Contain);

          Flex() {
            Column() {
              Text($$.marker.getTitle())
                .fontSize($r('app.string.font_size_12'))
                .margin({
                  bottom: $r('app.string.margin_s'),
                });
              Text($$.marker.getSnippet())
                .fontSize($r('app.string.font_size_12'))
                .fontColor($r('app.color.font_color_level2'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
            }
            .alignItems(HorizontalAlign.Start);


            Divider()
              .vertical(true)
              .margin($r('app.string.margin_s'));

            Column() {
              Image($r('app.media.ic_guide'))
                .width(18)
                .margin({ bottom: $r('app.string.margin_xs') });
              Text('导航')
                .fontSize($r('app.string.font_size_12'))
                .fontColor($r('app.color.font_color_link'))
                .maxLines(1);
            }
            .width(40)
            .padding({ right: $r('app.string.padding_s') })
            .onClick(() => {
              this.vm.handleClickGuide();
            });
          }
          .padding(12)
          .margin({ left: $r('app.string.margin_s') });
        }
        .width('70%');
      }
      .width('100%')
      .alignItems(HorizontalAlign.End)
      .height(70);
    }
  }
}

export {
  StoreMap, StoreMapVM };

export { mapOptionsDialog } from './MapOptionDialog';