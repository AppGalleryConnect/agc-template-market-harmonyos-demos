import { BaseViewModel, CommonConstants, TabBarType,
  VideoType } from '@ohos_agcit/driver_license_exam_commonlib';
import { PhoneConstants, TAB_LIST } from '../constants/Constants';

@ObservedV2
export class MainEntryVM extends BaseViewModel {

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
      return PhoneConstants.LEFT_TAB_BAR_ITEM_HEIGHT * TAB_LIST.length;
    }
    return PhoneConstants.BOTTOM_TAB_BAR_HEIGHT;
  }
  @Computed
  get showDivider(): DividerStyle | null {
    if (!this.tabModel.isTabVertical) {
      return null;
    }
    if ([TabBarType.HOME, TabBarType.COMMUNITY].includes(this.tabModel.selectedIndex)) {
      return null;
    }
    if (this.hideTabScene) {
      return null;
    }
    return {
      strokeWidth: '1px',
      color: $r('sys.color.comp_divider'),
      startMargin: 0,
      endMargin: 0,
    } as DividerStyle
  }

  // 存在隐藏Tab的场景
  @Computed
  get hideTabScene() {
    return this.tabModel.selectedIndex === TabBarType.VIDEO &&
      [VideoType.FOLLOW, VideoType.CHOICE].includes(this.tabModel.videoCurrentTabIndex);
  }
}