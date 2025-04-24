
import { PackagesCardView } from './PackagesCardView'
import { PackageCardModel } from '../model/packageModel'
import { PackageVM } from '../model/PackageVM'
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@Builder
export function PackageViewBuilder() {
  PackageView()
}

@ComponentV2
struct PackageView {
  topRectHeight: number = 0;
  packageVM: PackageVM = PackageVM.instance;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  build() {
    NavDestination() {
      Column() {
        List({space:8}) {
         ForEach(this.packageVM.packageData,(item: PackageCardModel) => {
           ListItem() {
             PackagesCardView({
               card: item
             })
           }
           .padding(8)
           .backgroundColor(Color.White)
           .borderRadius(8)
         })
        }
        .width(CommonConstants.FULL_WIDTH)
      }
      .height(CommonConstants.FULL_HEIGHT)
      .padding(10)
      .backgroundColor('#eee')
    }
    .title('套餐列表')
    .margin({
      top: px2vp(this.topRectHeight)
    })
    .onBackPressed(() => {
      this.appPathStack.pop()
      return true;
    })
    .linearGradient({
      angle:135,
      colors:[['#D2E2F5', 0.0], ['#F1F3F5', 0.4]]
    })


  }
}
