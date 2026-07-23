import { CommonConstants } from 'commonlib';
import { DrawBoardVM } from '../viewmodel/DrawBoardVM';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM'




@ComponentV2
export struct DrawBoard {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  drawVM: DrawBoardVM = this.vm.drawBoardVM;

  build() {
    Canvas(this.drawVM.scrawlContext)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .onReady(() => {
        this.drawVM.initDrawBoard();
      })
      .onAreaChange((oldValue: Area, newValue: Area) => {
        const oldWidth: number = oldValue.width as number;
        const newWidth: number = newValue.width as number;
        const oldHeight: number = oldValue.height as number;
        const newHeight: number = newValue.height as number;
        if (oldWidth !== newWidth || oldHeight !== newHeight) {
          this.drawVM.renderWithCache();
        }
      })
      .onTouch((event: TouchEvent) => {
        this.drawVM.handleTouch(event)
      })
  }
}