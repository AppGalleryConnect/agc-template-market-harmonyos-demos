import { CommonConstants } from 'commonlib';
import { MosaicVM } from '../viewmodel/MosaicVM';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM'


@ComponentV2
export struct MosaicComponent {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  mosaicVM: MosaicVM = this.vm.mosaicVM;

  build() {
    Canvas(this.mosaicVM.drawContext)
      .id('canvas')
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.mosaicVM.canvasAreaChange(newValue)
      })
      .onGestureRecognizerJudgeBegin((event: BaseGestureEvent, current: GestureRecognizer,
        others: Array<GestureRecognizer>) => {
        if (!this.mosaicVM.mosaicSource) {
          return GestureJudgeResult.REJECT;
        }
        if (current.getEventTargetInfo()?.getId() === 'canvas' &&
          current.getType() === GestureControl.GestureType.PAN_GESTURE) {
          return GestureJudgeResult.CONTINUE;
        }
        return GestureJudgeResult.CONTINUE;
      })
      .gesture(
        PanGesture()
          .onActionStart((event: GestureEvent) => {
            let finger: FingerInfo = event.fingerList[0];
            if (finger === undefined) {
              return
            }
            let x = finger.localX
            let y = finger.localY
            this.vm.isShowMosaicOperateBar = false;
            this.mosaicVM.moveStart(x, y)
          })
          .onActionUpdate((event: GestureEvent) => {
            let finger: FingerInfo = event.fingerList[0];
            if (finger === undefined) {
              return
            }
            let x = finger.localX
            let y = finger.localY
            this.vm.isShowMosaicOperateBar = true;
            this.mosaicVM.moveUpdate(x, y)
          })
          .onActionEnd((event: GestureEvent) => {
            let finger: FingerInfo = event.fingerList[0];
            if (finger === undefined) {
              return
            }
            this.mosaicVM.moveEnd()
          }),
      )

  }
}