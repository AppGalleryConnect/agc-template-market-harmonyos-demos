import { ShowCardView } from './ShopCardView'
import { ShopCardModel } from '../model/ShopModel'
import { LocationVM } from '../model/LocationVM'
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@Builder
export function ShowViewBuilder() {
  ShopView()
}


@ComponentV2
// 门店展示列表
struct ShopView {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  topRectHeight: number = 0;
  locationVM: LocationVM = LocationVM.instance;
  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  build() {
    NavDestination() {
      Row() {
        List({space:12}) {
          ForEach(this.locationVM.shopCardList, (item:ShopCardModel) => {
            ListItem() {
               ShowCardView({
                card:item
              })
            }
            .backgroundColor('#fff')
            .borderRadius(16)
            .padding(12)
          })
        }
        .width(CommonConstants.FULL_WIDTH)
      }
      .height(CommonConstants.FULL_HEIGHT)
      .padding({
        top:12,
        bottom:12,
        left: 16,
        right: 16
      })
      .backgroundColor('#eee')
      .alignItems(VerticalAlign.Top)
    }
    .title('门店列表')
    .margin({
      top:px2vp(this.topRectHeight)
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })
    .linearGradient({
      angle:135,
      colors:[['#D2E2F5', 0.0], ['#F1F3F5', 0.4]]
    })

  }
}
