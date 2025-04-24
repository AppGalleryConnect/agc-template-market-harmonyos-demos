import { ListItemCard } from './ListItemCard';
import { CateringInfo } from 'types';
import { CateringPageVM } from '../viewmodel/CateringPageVM';
import { https } from 'network';

@Builder
export function CateringComponentBuilder() {
  CateringComponent();
}

@ComponentV2
export struct CateringComponent {
  vm: CateringPageVM = CateringPageVM.instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      List({ space: 12 }) {
        LazyForEach(this.vm.cateringList, (item: CateringInfo) => {
          ListItem() {
            ListItemCard({
              data: item, routeToDetailPage: () => {
                https.getCateringDetail(item.siteId).then((res) => {
                  item.banners = res.data.banner;
                  item.startPrice = res.data.startPrice;
                  item.detailImages = res.data.images;
                  item.detail = res.data.detail;
                  item.openHours = res.data.openHours;
                  this.mainPathStack.pushPathByName('CateringDetail', item);
                });
              },
            });
          }.padding(16).backgroundColor(Color.White).borderRadius(8);
        }, (item: CateringInfo) => item.siteId);
      }.cachedCount(8).backgroundColor('#F1F3F5').scrollBar(BarState.Off).height('90%');
    };
  }
}