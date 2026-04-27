import { AppStorageV2, display } from '@kit.ArkUI';
import { DisplayModel } from '../model/DisplayModel';

@ObservedV2
export class PrompterVM {
  // 横屏与折叠屏检查
  @Trace displayModel: DisplayModel = AppStorageV2.connect(DisplayModel, () => new DisplayModel())!;

  // 监听设备屏幕方向折叠状态改变
  displayOrientationListener() {
    this.displayModel.isFoldAble = display.isFoldable();
    this.displayModel.isFullMode = display.isFoldable() ? display.getFoldStatus() !== 2 : false
    try {
      display.on('change', (type: number) => {
        let displayClass = display.getDisplayByIdSync(type);
        // 横屏
        let landscapeType = [display.Orientation.LANDSCAPE, display.Orientation.LANDSCAPE_INVERTED]
        this.displayModel.isLandscape = landscapeType.includes(displayClass.orientation);
      })
      display.on('foldDisplayModeChange', (data: display.FoldDisplayMode) => {
        this.displayModel.isFullMode = data === display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL
      })
    } catch (e) {
    }
  }
}
