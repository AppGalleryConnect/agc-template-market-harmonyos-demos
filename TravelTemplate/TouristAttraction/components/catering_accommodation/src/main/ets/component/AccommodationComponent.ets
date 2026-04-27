import { https } from 'module_base';
import { AccommodationInfo } from '../model/Index';
import { CateringPageVM } from '../viewmodel/CateringPageVM';
import { ListItemCard } from './ListItemCard';
import { CateringTabBarType } from '../model/Index';

@Builder
export function AccommodationComponentBuilder() {
  AccommodationComponent();
}

@ComponentV2
export struct AccommodationComponent {
  vm: CateringPageVM = CateringPageVM._instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      List({ space: 12 }) {
        LazyForEach(this.vm.accommodationList, (item: AccommodationInfo) => {
          ListItem() {
            ListItemCard({
              type: CateringTabBarType.ACCOMMODATION, data: item, routeToDetailPage: () => {
                https.getAccommodationDetail(item.siteId).then((res) => {
                  item.banners = res.data.banner;
                  item.detailImages = res.data.images;
                  item.detail = res.data.detail;
                  item.labels = res.data.label;
                  this.mainPathStack.pushPathByName('AccommodationDetail', item);
                });
              },
            });
          }.padding(16).backgroundColor($r('sys.color.font_on_primary')).borderRadius(8);
        }, (item: AccommodationInfo) => item.siteId);
      }.scrollBar(BarState.Off).backgroundColor('#F1F3F5').height('90%').padding(12);
    };
  }
}