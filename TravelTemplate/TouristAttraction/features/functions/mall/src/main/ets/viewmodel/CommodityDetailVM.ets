import { doRandBySync, getFormatTime } from 'common';
import { CreateCommodityOrderRequest, GetCommodityDetailResp, GetOrderDetailRequest, https } from 'network';
import { AddressInfo } from 'types';
import { CommodityInfo, PurchaseInfo } from '../model/CommodityInfo';

@ObservedV2
export class CommodityDetailVM {
  @Trace count: number = 1;
  @Trace addressInfo: AddressInfo = new AddressInfo();
  public static _instance: CommodityDetailVM;

  public static get instance() {
    if (!CommodityDetailVM._instance) {
      CommodityDetailVM._instance = new CommodityDetailVM();
    }
    return CommodityDetailVM._instance;
  }

  createOrder(purchaseInfo: PurchaseInfo, pathStack: NavPathStack) {
    let commodityOrderRequest: CreateCommodityOrderRequest = {
      orderNo: doRandBySync(6),
      orderTime: getFormatTime(new Date()),
      orderStatus: 1,
      addressId: this.addressInfo.id,
      couponId: 0,
      count: this.count,
      productName: purchaseInfo.commodityInfo.name,
      disCountPrice: purchaseInfo.commodityInfo.spuInfo[purchaseInfo.selectedSpu].spuDiscountPrice,
      freight: 0,
      amount: purchaseInfo.commodityInfo.spuInfo[purchaseInfo.selectedSpu].spuDiscountPrice * this.count,
      discount: 0,
      banner: purchaseInfo.commodityInfo.banner,
      originalPrice: purchaseInfo.commodityInfo.spuInfo[purchaseInfo.selectedSpu].spuOriginalPrice,
      spuName: purchaseInfo.commodityInfo.spuInfo[purchaseInfo.selectedSpu].spuName,
    };

    https.createCommodityOrder(commodityOrderRequest).then((res) => {
      if (res.code === 0) {
        pathStack.pushPathByName('CommodityOrderDetail', {
          category: 1,
          orderNo: commodityOrderRequest.orderNo,
        } as GetOrderDetailRequest);
      }
    });
  }

  mapPurchaseParam(commodityInfo: CommodityInfo, selectedSpu: number) {
    let purchaseInfo = new PurchaseInfo();
    purchaseInfo.commodityInfo = commodityInfo;
    purchaseInfo.selectedSpu = selectedSpu;
    return purchaseInfo;
  }
}