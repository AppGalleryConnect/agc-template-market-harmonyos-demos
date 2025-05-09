import { TabsIndexMap } from '../constants/CommonEnums';
import { RouterModule } from './RouterModule';

@ObservedV2
export class FrameworkUtil {
  @Trace static currentIndex: number = 0;
  static tabController: TabsController = new TabsController();


  public static switchTab(tab: TabsIndexMap) {
    FrameworkUtil.tabController?.changeIndex(tab);
    FrameworkUtil.currentIndex = tab;
  }

  public static backToHome() {
    RouterModule.clear();
    FrameworkUtil.switchTab(TabsIndexMap.HOME);
  }
}