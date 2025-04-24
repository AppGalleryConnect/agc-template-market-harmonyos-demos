import { https } from 'network';
import { AccommodationInfo } from 'types';
import { CateringPageVM } from '../viewmodel/CateringPageVM';
import { ListItemCard } from './ListItemCard';

@Builder
export function AccommodationComponentBuilder() {
  AccommodationComponent();
}

@ComponentV2
export struct AccommodationComponent {
  vm: CateringPageVM = CateringPageVM.instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      List({ space: 12 }) {
        LazyForEach(this.vm.accommodationList, (item: AccommodationInfo) => {
          ListItem() {
            ListItemCard({
              data: item, routeToDetailPage: () => {
                https.getAccommodationDetail(item.siteId).then((res) => {
                  item.banners = res.data.banner;
                  item.detailImages = res.data.images;
                  item.detail = res.data.detail;
                  item.labels = res.data.labels;
                  this.mainPathStack.pushPathByName('AccommodationDetail', item);
                });
              },
            });
          }.padding(16).backgroundColor(Color.White).borderRadius(8);
        }, (item: AccommodationInfo) => item.siteId);
      }.scrollBar(BarState.Off).backgroundColor('#F1F3F5').height('90%');
    };
  }
}