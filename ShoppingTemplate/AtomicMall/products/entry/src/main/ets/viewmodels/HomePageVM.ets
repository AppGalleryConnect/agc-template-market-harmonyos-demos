import {
  LoadingStatus,
  routerStack,
  RouterMap,
  GlobalStateMgr,
  iData,
  BreakpointSystem,
  BreakpointTypeEnum,
  PushUtil,
  PermissionUtil,
} from 'lib_foundation';
import { CategoryItem } from 'lib_network';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';
import { PreloadUtil } from '../utils/PreloadUtil';

@ObservedV2
export class HomePageVM {
  public readonly global: GlobalStateMgr = iData.global;
  @Trace
  public loadingStatus: LoadingStatus = LoadingStatus.LOADING;
  @Trace
  public refreshStatus: RefreshStatus = RefreshStatus.Inactive;
  @Trace
  public isRefreshing: boolean = false;
  @Trace
  bannerList: string[] = [];
  @Trace
  categoryList: CategoryItem[] = [];
  @Trace
  searchList: string[] = [];
  @Trace
  currentSearchStr: string = '';

  @Computed
  get isTablet() {
    return BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG;
  }

  public onRefreshStateChange(state: RefreshStatus): void {
    this.refreshStatus = state;
    if (state === RefreshStatus.Refresh) {
      this.loadHomePage();
    }
  }

  public async loadHomePage(): Promise<void> {
    this.loadingStatus = LoadingStatus.LOADING;
    try {
      const res = await PreloadUtil.getPreloadData();
      if (res?.code === 0) {
        this.categoryList = res.categoryList;
        this.searchList = res.searchList;
        this.bannerList = res.bannerList;
        this.currentSearchStr = res.searchList[0];
      }
      this.loadingStatus = LoadingStatus.SUCCESS;
    } catch (e) {
      this.loadingStatus = LoadingStatus.FAIL;
    }
    this.isRefreshing = false;
    // todo: 填写推送模板订阅ID
    PermissionUtil.requestSubscribeNotification('xxx').then((res) => {
      if (res) {
        PushUtil.pushMessageMock()
      }
    })
  }

  public jumpToCategoryPage(id: string) {
    routerStack.pushPathByName(RouterMap.PRODUCT_CATEGORY, id);
  }

  public jumpToSearchPage(uiContext: UIContext, snapShotComponentId: string) {
    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(uiContext, snapShotComponentId, 9);
    const param: Record<string, Object | undefined> = {
      'snapShotId': snapShotComponentId,
      'longTakeTransitionParam': longTakeTransitionParam,
      'defaultSearch': this.currentSearchStr,
    };
    routerStack.pushPath({
      name: RouterMap.PRODUCT_SEARCH,
      param,
    });
  }

}
