import { LoadingDialog } from '@kit.ArkUI';
import { NavTitle } from '../components/NavTitle';
import { SavePhotoPageVM } from '../viewModels/SavePhotoPageVM';


@Builder
export function SavePhotoPageBuilder() {
  SavePhotoPage();
}

@ComponentV2
export struct SavePhotoPage {
  vm: SavePhotoPageVM = SavePhotoPageVM.instance;
  loadingController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      content: '照片保存中...',
    }),
    autoCancel:false
  });

  aboutToAppear(): void {
    this.vm.getRouteParam();
    this.vm.showLoading = this.showLoading
    this.vm.closeLoading = this.closeLoading
  }

  build() {
    NavDestination() {
      NavTitle({
        text: '保存照片',
      });
      Column() {
        if (this.vm.img) {
          Image(this.vm.img).width(240).height(240 * this.vm.ratio);
        }

      }.layoutWeight(1).padding({ left: 16, right: 16, top: 70 });

      Column() {
        SaveButton().height(40).width('100%').constraintSize({ maxWidth: 328 })
          .onClick((event: ClickEvent, result: SaveButtonOnClickResult) => {
            if (result === SaveButtonOnClickResult.SUCCESS) {
              this.vm.savePhoto(this.getUIContext().getHostContext());
            }
          });
      }.width('100%').height(56).padding({ left: 16, right: 16 }).margin({ bottom: 20 });
    }.hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'));

  }

  private showLoading = () => {
    this.loadingController.open();
  };

  private closeLoading = () => {
    this.loadingController.close();
  };
}