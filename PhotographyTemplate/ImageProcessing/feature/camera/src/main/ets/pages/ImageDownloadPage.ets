import { OperateType, RouterMap, RouterModule, BeautyParam, BaseTitle, CommonConstants } from 'commonlib';
import { ImageDownloadPageVM } from '../viewmodel/ImageDownloadPageVM';

@Builder
export function ImageDownloadBuilder() {
  ImageDownload();
}

@ComponentV2
export struct ImageDownload {
  vm: ImageDownloadPageVM = new ImageDownloadPageVM();

  aboutToAppear(): void {
    this.vm.getRouteParm();
  }

  build() {
    NavDestination() {
      BaseTitle({
        showBackBtn: true,
        titleFontSize: $r('sys.float.Title_S'),
        fontColor: Color.White,
        btnBgColor: 'rgba(255, 255, 255, 0.1)'
      })
      Column({ space: 80 }) {
        Column() {
          Image(this.vm.capturePixelmap).objectFit(ImageFit.Contain)
        }
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)

        this.bottomBtnBar()
      }
      .width('100%')
      .layoutWeight(1);
    }
    .hideTitleBar(true)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({ left: 16, right: 16, bottom: 16 })
    .backgroundColor($r('sys.color.comp_foreground_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  @Builder
  bottomBtnBar() {
    Row({ space: 64 }) {
      Column({ space: 4 }) {
        SymbolGlyph($r('sys.symbol.arrow_left_circle'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_on_primary')])
        Text('返回').fontSize(14).fontColor($r('sys.color.font_on_primary'))
      }
      .onClick(() => {
        RouterModule.pop();
      });

      SaveButton({ icon: SaveIconStyle.FULL_FILLED, buttonType: ButtonType.Circle })
        .size({ width: 48, height: 48 })
        .backgroundColor($r('sys.color.icon_on_primary'))
        .iconColor($r('sys.color.font_primary'))
        .onClick(() => {
          const context = this.getUIContext().getHostContext() as Context
          this.vm.handleSaveButtonClick(context);
        });

      Column({ space: 4 }) {
        SymbolGlyph($r('sys.symbol.edit_badge_star'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_on_primary')])
        Text('编辑').fontSize(14).fontColor($r('sys.color.font_on_primary'))
      }
      .onClick(() => {
        this.vm.handleEditButtonClick();
      });
    }
  }
}