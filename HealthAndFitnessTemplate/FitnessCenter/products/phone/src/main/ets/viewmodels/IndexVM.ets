import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { BaseViewModel, BreakpointNameEnum, CommonConstants } from 'external_interactions';
import { PhoneConstants, TabBarType, TABS_INFO } from '../common/TabConstants';

/**
 * 自由流转-应用接续模型
 */
@ObservedV2
export class ContinueModel {
  @Trace id: number = 0;
  @Trace newsId: string = '';
  @Trace playerProgress: number = 0;
  @Trace scrollOffset: number = 0;
  @Trace breakpoint: string = BreakpointNameEnum.SM;
  @Trace isTargetDevice: boolean = false;
}

@ObservedV2
export class IndexPageViewModel extends BaseViewModel {
  @Trace translateY: string | number = '';
  @Trace firstBackTime: number = 0;
  @Trace continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;

  @Monitor('tabModel.showTabBar')
  onChangeShowTabBar(monitor: IMonitor) {
    if (this.tabModel.isTabVertical) {
      return;
    }
    let isShowCustomTabBar = monitor.value()?.now as boolean;
    if (isShowCustomTabBar) {
      this.translateY = '';
    } else {
      this.translateY = '100%';
    }
  }

  @Monitor('tabModel.isTabVertical')
  onShowChangeTabBar(monitor: IMonitor) {
    let isShowCustomTabBar = monitor.value()?.now as boolean
    if (isShowCustomTabBar) {
      this.translateY = '';
    }
  }

  @Computed
  get barPosition() {
    if (this.tabModel.isTabVertical) {
      return BarPosition.Start;
    }
    return BarPosition.End;
  }

  @Computed
  get tabWidth(): Length {
    if (this.tabModel.isTabVertical) {
      return PhoneConstants.LEFT_TAB_BAR_WIDTH;
    }
    return CommonConstants.FULL_PERCENT;
  }

  @Computed
  get tabHeight(): Length {
    if (this.tabModel.isTabVertical) {
      return PhoneConstants.LEFT_TAB_BAR_ITEM_HEIGHT * TABS_INFO.length;
    }
    return 70;
  }

  @Computed
  get showDivider(): DividerStyle | null {
    if (!this.tabModel.isTabVertical) {
      return null;
    }
    if ([TabBarType.HOME, TabBarType.RECORD].includes(this.tabModel.selectedIndex)) {
      return null;
    }
    return {
      strokeWidth: '1px',
      color: $r('sys.color.comp_divider'),
      startMargin: 0,
      endMargin: 0,
    } as DividerStyle
  }

  @Computed
  get getBgColor(): ResourceColor {
    return '#FFFFFF';
  }
}