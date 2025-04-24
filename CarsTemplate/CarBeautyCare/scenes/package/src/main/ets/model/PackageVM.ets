import { LocationVM, ShopCardModel } from '@ohos_agcit/car_beauty_care_shop'
import { PACKAGE_DATA, PackageCardModel } from './packageModel'

@ObservedV2
export class PackageVM {
  private static _instance: PackageVM;
  locationVM: LocationVM = LocationVM.instance;
  @Trace packageData:PackageCardModel[] = [];
  @Trace selectPackageData: PackageCardModel = PACKAGE_DATA[0];


  public static get instance() {
    if (!PackageVM._instance) {
      PackageVM._instance = new PackageVM();
      PackageVM._instance.setPackageData();
    }
    return PackageVM._instance;
  }

  @Monitor('locationVM.selectShopData')
  shopChange() {
    this.setPackageData();
  }

  private setPackageData() {
    const shopId:string = this.locationVM.selectShopData.id;
    this.packageData = PACKAGE_DATA.filter((item:PackageCardModel) => item.shopId === shopId);
  }

  public updatePackageSelect(data:PackageCardModel) {
    this.selectPackageData = data;
  }
}