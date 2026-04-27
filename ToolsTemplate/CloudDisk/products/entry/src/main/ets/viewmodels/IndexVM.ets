import { display } from '@kit.ArkUI';
import { BaseViewModel, BreakpointUtils } from 'common';

@ObservedV2
export class IndexVM extends BaseViewModel {
  breakpoint: BreakpointUtils | null = null;

  // 监听设备屏幕方向改变
  displayOrientationListener() {
    this.displayModel.isFoldable = display.isFoldable();
    try {
      display.on('change', (type: number) => {
        let displayClass = display.getDisplayByIdSync(type);
        // 横屏
        let landscapeType = [display.Orientation.LANDSCAPE, display.Orientation.LANDSCAPE_INVERTED]
        this.displayModel.isLandscape = landscapeType.includes(displayClass.orientation);
      })
    } catch (e) {
    }
  }

  registerBreakpointListener(context: UIContext) {
    this.breakpoint = new BreakpointUtils(context.getMediaQuery());
    this.breakpoint?.register();
  }

  unregisterBreakpointListener() {
    this.breakpoint?.unRegister();
  }
}
