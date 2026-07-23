import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants } from 'lib_foundation';
import { BreakpointModel } from 'module_weather_core';
import { TabItemModel } from '../types/Types';

@ObservedV2
export class MainVM {
  // 页签索引
  @Trace curIndex: number = 0;
  @Trace breakpointModel: BreakpointModel =
    AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  public controller: TabsController = new TabsController();
  public tabList: TabItemModel[] = [
    {
      label: $r('app.string.tab_home'),
      icon: $r('app.media.ic_tab0'),
      iconSelected: $r('app.media.ic_tab0_selected'),
    },
    {
      label: $r('app.string.tab_mine'),
      icon: $r('app.media.ic_tab1'),
      iconSelected: $r('app.media.ic_tab1_selected'),
    },
  ];
  private static _instance: MainVM;

  public static get instance() {
    if (!MainVM._instance) {
      MainVM._instance = new MainVM();
    }
    return MainVM._instance;
  }

  @Computed
  get isLargeWindow(): boolean {
    return this.breakpointModel.isLargeWindow;
  }

  @Computed
  get tabBarHeight(): string | number {
    return this.isLargeWindow ? 200 * 2 : 70;
  }

  @Computed
  get tabBarWidth(): string | number {
    return this.isLargeWindow ? 88 : CommonConstants.FULL_PERCENT;
  }

  @Computed
  get tabVertical(): boolean {
    return this.isLargeWindow;
  }

  @Computed
  get tabBarPosition(): BarPosition {
    return this.isLargeWindow ? BarPosition.Start : BarPosition.End;
  }

  @Computed
  get tabItemHeight(): string | number {
    return this.isLargeWindow ? 200 : CommonConstants.FULL_PERCENT;
  }

  @Computed
  get tabItemTopPadding(): number {
    return this.isLargeWindow ? CommonConstants.SPACE_12 : CommonConstants.SPACE_6;
  }
}
