import { AppStorageV2, display, PersistenceV2 } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { BreakpointModel, BreakpointNameEnum, BreakpointUtils, DisplayModel, ThemeModel } from 'common';
import { PhoneConstants } from '../constants/Contants';

const TAG = '[IndexVM]';

@ObservedV2
export class IndexVM {
  @Trace isShowAd: boolean = false;
  @Trace isEnabled: boolean = true;
  breakpoint: BreakpointUtils | null = null;
  @Trace displayModel: DisplayModel = AppStorageV2.connect(DisplayModel, () => new DisplayModel())!;
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;

  @Computed
  get tabItemHeight(): Length {
    if (this.isTabVertical) {
      return PhoneConstants.LEFT_TAB_BAR_ITEM_HEIGHT;
    }
    return PhoneConstants.BOTTOM_TAB_BAR_HEIGHT;
  }

  registerBreakpointListener(context: UIContext) {
    this.breakpoint = new BreakpointUtils(context.getMediaQuery());
    this.breakpoint?.register();
  }

  unregisterBreakpointListener() {
    this.breakpoint?.unRegister();
  }


  // 是否纵向Tab
  @Computed
  get isTabVertical() {
    return [
      BreakpointNameEnum.LG,
      BreakpointNameEnum.XL,
    ].includes(this.breakPointModel.currentBreakpoint);
  }

  @Computed
  get tabHeight(): Length {
    if (this.isTabVertical) {
      return '100%';
    }
    return PhoneConstants.BOTTOM_TAB_BAR_HEIGHT;
  }

  @Computed
  get tabBarHeight() {
    return this.tabHeight
  }

  @Computed
  get tabWidth(): Length {
    if (this.isTabVertical) {
      return PhoneConstants.LEFT_TAB_BAR_WIDTH;
    }
    return '100%';
  }

  @Computed
  get barPosition() {
    if (this.isTabVertical) {
      return BarPosition.Start;
    }
    return BarPosition.End;
  }

  // 监听设备屏幕方向改变
  displayOrientationListener() {
    try {
      this.displayModel.isFoldable = display.isFoldable();
      display.on('change', (type: number) => {
        let displayClass = display.getDisplayByIdSync(type);
        // 横屏
        let landscapeType = [display.Orientation.LANDSCAPE, display.Orientation.LANDSCAPE_INVERTED]
        this.displayModel.isLandscape = landscapeType.includes(displayClass.orientation);
      })
    } catch (e) {
      UtilLog.error(TAG, 'displayOrientationListener fail, error: ' + JSON.stringify(e));
    }
  }
}
