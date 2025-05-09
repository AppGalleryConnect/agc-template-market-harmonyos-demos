import { PermissionUtil, RouterMap, RouterModule, StoreInfo } from 'commonlib';
import { StoreMapVM } from 'componentlib';

@ObservedV2
export class LocationVM {
  @Trace storeInfo: StoreInfo | null = null;
  @Trace isLoading: boolean = false;
  private static _instance: LocationVM;
  mapVM: StoreMapVM = StoreMapVM.instance;

  public static get instance() {
    if (!LocationVM._instance) {
      LocationVM._instance = new LocationVM();
    }
    return LocationVM._instance;
  }

  public initStoreInfo() {
    const param = RouterModule.getNavParam<StoreInfo>({
      url: RouterMap.HOME_LOCATION,
    });
    if (param) {
      this.storeInfo = param;
    }
    this.requestLocationPermission();
  }

  public requestLocationPermission() {
    PermissionUtil.requestPermissions(['ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION'])
      .then(() => {
        this.mapVM.setUserLocation();
      });
  }


  public jumpToGuide() {
    this.mapVM.handleClickGuide();
  }
}