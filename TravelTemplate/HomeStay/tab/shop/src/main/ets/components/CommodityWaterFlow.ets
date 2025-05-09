import { Constants, NavPathName } from 'constant';
import { ContentCard } from './ContentCard';
import { Commodity } from 'type';
import { ShopPageVM } from '../viewmodel/ShopPageVM';
import { CommonBlank } from 'component';

@Builder
export function CommodityWaterFlowBuilder() {
  CommodityWaterFlow();
}

@Component
export struct CommodityWaterFlow {
  vm: ShopPageVM = ShopPageVM.instance;
  @Consume('mainPathStack') mainPathStack: NavPathStack;

  build() {
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
      .enableScrollInteraction(false)
      .cachedCount(10)
      .columnsTemplate('1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .width(Constants.FULL_SCREEN);
    } else {
      CommonBlank();
    }
  }
}