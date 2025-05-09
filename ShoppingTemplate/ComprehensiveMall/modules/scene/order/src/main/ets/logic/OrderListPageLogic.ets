import { OrderCardDto, OrderCardVM } from '@common/customtypes';
import { client } from '@common/network';


@ObservedV2
export class OrderListPageLogic {

  @Trace
  public isLoading: boolean = true;

  @Trace
  public orderCards: OrderCardVM[] = [];

  @Trace
  public type: number = 0;

  @Trace
  public showLoading: boolean = false;

  public readonly refresh = (needLoading: boolean = true): void => {
    this.isLoading = needLoading;
    client.order.getOrderList(this.type)
      .then((cards: OrderCardDto[]) => {
        const orderCards: OrderCardVM[] = [];
        for (let i: number = cards.length - 1; i >= 0; i--) {
          const card: OrderCardVM = new OrderCardVM();
          card.type = cards[i].type;
          card.time = cards[i].time;
          card.orderCode = cards[i].orderCode;
          card.statusDesc = cards[i].statusDesc;
          card.skuList = cards[i].skuList;
          card.logisticsInfo = cards[i].logisticsInfo;
          card.totalPrice = cards[i].totalPrice;
          orderCards.push(card);
        }
        this.orderCards = orderCards;
        this.isLoading = false;
      })
      .finally(() => this.showLoading = false)
  }
}
