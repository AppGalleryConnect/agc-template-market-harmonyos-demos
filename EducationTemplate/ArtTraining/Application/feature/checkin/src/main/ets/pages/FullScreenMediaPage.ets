import { PickerResourceType } from 'commonlib';
import { CommonHeader } from 'componentlib';
import { FullScreenMediaVM } from '../viewmodels/FullScreenMediaVM';

@Builder
export function fullScreenMediaPageBuilder() {
  FullScreenMediaPage();
}

@ComponentV2
export struct FullScreenMediaPage {
  vm: FullScreenMediaVM = FullScreenMediaVM.instance;

  build() {
    NavDestination() {
      CommonHeader({ title: this.vm.pageTitle });
      Column() {
        if (this.vm.mediaType === PickerResourceType.IMAGE) {
          this.imageCardBuilder();
        } else if (this.vm.mediaType === PickerResourceType.VIDEO) {
          this.videoCardBuilder();
        }
      }
      .layoutWeight(1);
    }
    .hideTitleBar(true)
    .onReady(()=> {
      this.vm.getMediaResource();
    })
  }

  @Builder
  imageCardBuilder() {
    if (this.vm.imageResource) {
      Scroll() {
        Image(this.vm.imageResource)
          .width($r('app.string.width_percent_full'))
      }
      .layoutWeight(1)
    }
  }

  @Builder
  videoCardBuilder() {
    if (this.vm.videoResource) {
      Video({
        src:this.vm.videoResource,
      })
        .width($r('app.string.width_percent_full'))
    }
  }
}