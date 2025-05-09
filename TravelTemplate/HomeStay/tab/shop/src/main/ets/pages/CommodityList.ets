import { CommonBlank, TitleBar } from 'component';
import { Constants, NavPathName } from 'constant';
import { Commodity } from 'type';
import { ContentCard } from '../components/ContentCard';
import { ShopPageVM } from '../viewmodel/ShopPageVM';

@Builder
export function CommodityListBuilder() {
  CommodityList();
}

@Component
export struct CommodityList {
  vm: ShopPageVM = ShopPageVM.instance;
  @Consume('mainPathStack') mainPathStack: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '商品列表', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        if (this.vm.commodityList.length !== 0) {
          WaterFlow() {
            ForEach(this.vm.commodityList, (item: Commodity) => {
              FlowItem() {
                ContentCard({
                  data: item,
                }).onClick(() => {
                  this.mainPathStack.pushPathByName(NavPathName.COMMODITY_DETAIL, item);
                });
              }
              .width(Constants.FULL_SCREEN);
            }, (item: Commodity) => item.id.toString());
          }
          .cachedCount(10)
          .columnsTemplate('1fr 1fr')
          .columnsGap(8)
          .rowsGap(8)
          .height('90%')
          .width(Constants.FULL_SCREEN)
          .padding(12);
        } else {
          CommonBlank();
        }
      };
    }.hideTitleBar(true);
  }
}