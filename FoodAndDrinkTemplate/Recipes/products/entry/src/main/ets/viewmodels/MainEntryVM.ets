import { AccountUtil, BreakpointModel, UserInfo } from 'commonlib';
import { FormCardJump, TabListItem } from '../types/Types';
import { HomePageBuilder } from 'home';
import { ClassificationPageBuilder } from 'classification';
import { MinePageBuilder } from 'mine';
import { AppStorageV2, SymbolGlyphModifier } from '@kit.ArkUI';
import { HealthyPageBuilder } from 'calories';

@ObservedV2
export class MainEntryVM {
  @Trace userInfo: UserInfo = AccountUtil.getUserInfo();
  @Trace formCardJump: FormCardJump = AppStorageV2.connect(FormCardJump, () => new FormCardJump())!;
  @Trace curIndex: number = 0;
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  public tabList: TabListItem[] = [
    {
      label: '首页',
      icon: $r('sys.symbol.house_fill'),
      component: wrapBuilder(HomePageBuilder),
    },
    {
      label: '分类',
      icon: $r('sys.symbol.square_fill_grid_2x2'),
      component: wrapBuilder(ClassificationPageBuilder),
    },
    {
      label: '健康',
      icon: $r('sys.symbol.waveform_path_ecg_heart_fill'),
      component: wrapBuilder(HealthyPageBuilder),
    },
    {
      label: '我的',
      icon: $r('sys.symbol.person_fill'),
      component: wrapBuilder(MinePageBuilder),
    },
  ];

  private static _instance: MainEntryVM;

  public static get instance() {
    if (!MainEntryVM._instance) {
      MainEntryVM._instance = new MainEntryVM();
    }
    return MainEntryVM._instance;
  }

  @Computed
  get breakPoint() {
    return this.breakPointModel.currentBreakpoint;
  }
}
