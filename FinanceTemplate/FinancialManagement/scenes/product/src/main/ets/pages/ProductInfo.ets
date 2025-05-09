import { ProductIntroduction } from '../components/productInfo/ProductIntroduction';
import { PurchaseProcess } from '../components/productInfo/PurchaseProcess';
import { PurchaseBar } from '../components/productInfo/PurchaseBar';
import { ProductInfoVM } from '../viewModels/ProductInfoVM';
import { HistoricalPerformance } from '../components/productInfo/HistoricalPerformance';
import { BuyRule } from '../components/productInfo/BuyRule';
import { RedemptionRule } from '../components/productInfo/RedemptionRule';
import { ProductReturns } from '../components/productInfo/ProductReturns';
import { CommonProductProfile } from 'componentlib';
import { FormatUtil, RouterMap } from 'commonlib';

@Builder
export function ProductInfoBuilder() {
  ProductInfo()
}

@ComponentV2
struct ProductInfo {
  vm: ProductInfoVM = ProductInfoVM.instance

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          //  产品介绍
          ProductIntroduction()
          //  交易时间
          PurchaseProcess()
          // 产品收益
          ProductReturns()
          // 历史业绩
          HistoricalPerformance()
          // 购买规则
          BuyRule()
          // 赎回规则
          RedemptionRule()
          //  产品档案
          CommonProductProfile({
            productProfile: this.vm.productProfile, changeFactory: (router: RouterMap, param?: ESObject) => {
              FormatUtil.jumpToNext(router, param)
            }
          })
        }
        .margin({ left: 16, right: 16 })
      }
      .scrollBar(BarState.Off)
      .height('calc(100% - 78vp)')

      //  购买状态栏
      PurchaseBar()
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('产品详情')
    .onShown(() => {
      this.vm.init()
    })
    .onHidden(() => {
      this.vm.clear();
    });
  }
}