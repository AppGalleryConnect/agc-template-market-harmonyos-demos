import { OrderSkuDto,
  PreOrderInfoDto,
  PreOrderRequest } from '@common/customtypes';
import { client } from '@common/network';
import { router } from '@common/router';
import { common } from '@kit.AbilityKit';
import { paymentService } from '@kit.PaymentKit';

@ObservedV2
export class OrderSubmitPageLogic {

  @Trace
  public isLoading: boolean = true;

  @Trace
  public skuList: OrderSkuDto[] = [];

  @Trace
  public totalPrice: number = 0;

  @Trace
  public addressDesc: string = '';

  @Trace
  public nickname: string = '';

  @Trace
  public phone: string = '';

  public readonly init = (preOrderRequest: PreOrderRequest | null) => {
    if (!preOrderRequest) {
      return;
    }
    client.order.getProOrderInfo(preOrderRequest)
      .then((info: PreOrderInfoDto) => {
        this.skuList = info.skuList;
        this.totalPrice = info.totalPrice;
        this.addressDesc = info.addressDesc;
        this.nickname = info.nickname;
        this.phone = info.phone;
        this.isLoading = false;
      });
  }

  public readonly onSubmit = () => {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    paymentService.requestPayment(context, '')
      .then(() => {
      })
      .catch(() => {
      })
      .finally(() => {
        router.replacePathByName('OrderBrowsingPage', 0);
      })
  }
}
