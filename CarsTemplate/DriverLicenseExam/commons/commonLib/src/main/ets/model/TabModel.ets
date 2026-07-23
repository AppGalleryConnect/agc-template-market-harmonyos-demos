import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointNameEnum } from '../constants/GridRowColSetting';
import { TabBarType } from '../constants/TabEnum';
import { VideoType } from '../constants/VideoEnum';
import { BreakpointModel } from './BreakpointModel';

/**
 * 应用的Tab信息
 */
@ObservedV2
export class TabModel {
  // 断点模型
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // 当前选择的tab下标
  @Trace selectedIndex: number = TabBarType.HOME;
  // 是否展示tab
  @Trace showTabBar: boolean = true;
  // tab的高度
  @Trace tabHeight: Length = '';
  // 视频tab页的头部tab
  @Trace videoCurrentTabIndex: number = VideoType.CHOICE;

  // 是否纵向Tab
  @Computed
  get isTabVertical() {
    return [
      BreakpointNameEnum.LG,
      BreakpointNameEnum.XL,
    ].includes(this.breakPointModel.currentBreakpoint);
  }
}

