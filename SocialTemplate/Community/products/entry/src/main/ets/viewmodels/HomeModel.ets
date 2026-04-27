import { TAB_CONFIG } from '../constants/Constants';
import { TabSingleItem } from './TabSingleItem';

@ObservedV2
export class HomeModel {
  @Trace curIndex: number = 0;
  public controller: TabsController = new TabsController();
  public tabList: TabSingleItem[] = TAB_CONFIG;
  private static _instance: HomeModel;

  public static get instance() {
    if (!HomeModel._instance) {
      HomeModel._instance = new HomeModel();
    }
    return HomeModel._instance;
  }
}