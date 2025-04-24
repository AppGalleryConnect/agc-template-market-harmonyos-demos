import { common } from '@kit.AbilityKit';
import { paymentService } from '@kit.PaymentKit';
import { GetMealDetailResp, GetOrderDetailRequest, https, PrepayMealRequest } from 'network';
import { BusinessError } from '@kit.BasicServicesKit';
import { AccountUtil, Logger, RouterMap, RouterModule } from 'commonlib';
import { MappedFoodInfo } from '../models/MappedFoodInfo';
import { promptAction } from '@kit.ArkUI';

@ObservedV2
export class MealOrderVM {
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Trace mealRequest: PrepayMealRequest | undefined = undefined;
  @Trace foodInfo: MappedFoodInfo | undefined = undefined;
  @Trace foodCount: number = 1;
  MAX_FOOD_COUNT: number = 10;
  private static _instance: MealOrderVM;

  public static get instance() {
    if (!MealOrderVM._instance) {
      MealOrderVM._instance = new MealOrderVM();
    }
    return MealOrderVM._instance;
  }

  public resetFoodCount() {
    this.foodCount = 1;
  }

  public handleFoodCount(isAdd: boolean = true) {
    if (isAdd && this.foodCount < this.MAX_FOOD_COUNT) {
      this.foodCount++;
    }
    if (!isAdd && this.foodCount > 1) {
      this.foodCount--;
    }
  }

  public getMealInfo(item: GetMealDetailResp) {
    this.mealRequest = {
      actualPaidPrice: (item.discountedPrice * this.foodCount).toString(),
      goodsId: item.id,
      goodsName: item.packageName,
      goodsPrice: item.discountedPrice.toString(),
      goodsQty: this.foodCount,
      orderType: '2',
      shopId: item.shopId,
      shopName: item.shopName,
      userId: AccountUtil.getUserInfo().id,
    };
  }

  public async prepayMeal() {
    if (!this.mealRequest || !this.foodInfo) {
      return;
    }
    this.mealRequest.goodsQty = this.foodCount;
    this.mealRequest.actualPaidPrice = (Number(this.foodInfo.promoPrice) * this.foodCount).toString();
    const res = await https.prepayMeal(this.mealRequest);
    if (res.code === 0) {
      paymentService
        .requestPayment(this.context, res.data.orderStr)
        .then(() => {
          Logger.info('succeeded in paying');
        })
        .catch((error: BusinessError) => {
          promptAction.showToast({ message: '支付失败！' });
          const timer = setTimeout(() => {
            RouterModule.push({
              url: RouterMap.ORDER_DETAIL,
              param: {
                orderNo: res.data.mercOrderNo,
                orderType: 2,
                userId: AccountUtil.getUserInfo().id,
              } as GetOrderDetailRequest,
            });
            clearTimeout(timer);
          }, 1000);
          Logger.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
        });
    }
  }
}
