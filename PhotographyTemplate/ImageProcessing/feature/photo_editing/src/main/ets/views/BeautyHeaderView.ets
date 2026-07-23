import { BaseTitle, OperateType, RouterMap, RouterModule } from 'commonlib';
import { ToolBarBtn } from '../components/ToolBarBtn';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';


@ComponentV2
export struct BeautyHeaderView {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;

  @Computed
  get canUndo() {
    return this.vm.totalLayerCount > 1 && this.vm.currentLayerIndex !== 0;
  }

  @Computed
  get canRedo() {
    return this.vm.totalLayerCount - 1 !== this.vm.currentLayerIndex;
  }

  build() {
    Row() {
      BaseTitle({
        showBackBtn: true,
        rightPartBuilder: () => {
          this.headerRightBuilder()
        },
        onBack: () => {
          if (this.vm.totalLayerCount > 1) {
            this.vm.showDiscardDialog();
          } else {
            RouterModule.pop();
          }
        }
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .zIndex(20)
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding,
    })
    .visibility(this.vm.operateType === OperateType.NONE ? Visibility.Visible : Visibility.None);
  }

  @Builder
  headerRightBuilder() {
    Row({ space: 10 }) {
      ToolBarBtn({
        symbol: 'sys.symbol.undo',
        enable: this.canUndo,
        onClickAction: () => {
          this.vm.undo();
        }
      })

      ToolBarBtn({
        symbol: 'sys.symbol.redo',
        enable: this.canRedo,
        onClickAction: () => {
          this.vm.redo();
        }
      })
      SaveButton({ icon: SaveIconStyle.FULL_FILLED, buttonType: ButtonType.Circle })
        .size({ width: 40, height: 40 })
        .iconColor($r('sys.color.font_primary'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          ImageProcessingUtil.saveToAlbum('ImageContent', this.getUIContext(), (uri: string) => {
            const param: Record<string, string | number> = {
              'url': uri,
              'imageRatio': this.vm.imageRatio
            }
            RouterModule.replace({ url: RouterMap.SHARE_IMAGE_PAGE, param: param })
          });
        });
    };
  }
}