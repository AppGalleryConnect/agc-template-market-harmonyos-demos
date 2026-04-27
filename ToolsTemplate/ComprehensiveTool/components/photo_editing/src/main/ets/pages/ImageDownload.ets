import { BeautyParam } from '../model/PageParams';
import { getInstance } from '../util/RouteModule';
import { CameraVM } from '../viewmodel/CameraVM';

@Builder
export function ImageDownloadBuilder() {
  ImageDownload();
}

@ComponentV2
export struct ImageDownload {
  vm: CameraVM = CameraVM.instance;

  build() {
    NavDestination() {
      Column() {
        Column({ space: 16 }) {
          Row() {
            Image($r('app.media.chevron_left_light')).size({ width: 40, height: 40 }).onClick(() => {
              getInstance().pop();
            });
          }.width('100%').justifyContent(FlexAlign.Start);

          Image(this.vm.capturePixelmap).height('calc(100% - 160vp)').width('100%');
        };

        Row() {
          Column({ space: 4 }) {
            Image($r('app.media.ic_save_arrow_left')).size({ height: 24, width: 24 });
            Text('返回').fontSize(14).fontColor($r('sys.color.font_on_primary')).onClick(() => {
              getInstance().pop();
            });
          }.layoutWeight(1).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);

          Column() {
            SaveButton({ icon: SaveIconStyle.FULL_FILLED, buttonType: ButtonType.Circle })
              .size({ width: 48, height: 48 })
              .onClick(() => {
                this.vm.handleSaveButtonClick(this.getUIContext());
              });
          }.layoutWeight(1);

          Column({ space: 4 }) {
            Image($r('app.media.ic_filter_edit')).size({ height: 24, width: 24 });
            Text('编辑').fontSize(14).fontColor($r('sys.color.font_on_primary')).onClick(() => {
              let param: BeautyParam = {
                uris: [],
                barIndex: -1,
                filterName: '',
                pixelMap: this.vm.pixelMap,
              };

              getInstance().pushPathByName('PictureBeautification', param);
            });
          }.layoutWeight(1);
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).height(48).alignItems(VerticalAlign.Center);
      }
      .padding({ left: 16, right: 16, bottom: 16 })
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.comp_foreground_primary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }.hideTitleBar(true).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}