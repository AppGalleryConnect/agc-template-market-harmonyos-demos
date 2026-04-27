import { https } from 'module_base';
import { CateringInfo } from '../model/Index';
import { ListItemCard } from './ListItemCard';
import { CateringPageVM } from '../viewmodel/CateringPageVM';
import { CateringTabBarType } from '../model/Index';

@Builder
export function CateringComponentBuilder() {
  CateringComponent();
}

@ComponentV2
export struct CateringComponent {
  vm: CateringPageVM = CateringPageVM._instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      List({ space: 12 }) {
        LazyForEach(this.vm.cateringList, (item: CateringInfo) => {
          ListItem() {
            ListItemCard({
              type: CateringTabBarType.CATERING, data: item, routeToDetailPage: () => {
                https.getCateringDetail(item.siteId).then((res) => {
                  item.banners = res.data.banner;
                  item.startPrice = res.data.startPrice;
                  item.detailImages = res.data.images;
                  item.detail = res.data.detail;
                  item.openHours = res.data.openHour;
                  this.mainPathStack.pushPathByName('CateringDetail', item);
                });
              },
            });
          }.padding(16).backgroundColor($r('sys.color.font_on_primary')).borderRadius(8);
        }, (item: CateringInfo) => item.siteId);
      }
      .cachedCount(8)
      .backgroundColor('#F1F3F5')
      .scrollBar(BarState.Off)
      .height('90%')
      .padding(12);
    };
  }
}