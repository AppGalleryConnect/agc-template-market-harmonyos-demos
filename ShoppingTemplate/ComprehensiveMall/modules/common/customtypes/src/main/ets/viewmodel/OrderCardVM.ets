import { LogisticsItemDto, OrderSkuDto } from '../ApiResponse';


@ObservedV2
export class OrderCardVM {

  @Trace
  public type: number = -1;

  @Trace
  public orderCode: string = '';

  @Trace
  public statusDesc: string = '';

  @Trace
  public skuList: OrderSkuDto[] = [];

  @Trace
  public logisticsInfo: LogisticsItemDto[] = [];

  @Trace
  public totalPrice: number = 0;

  @Trace
  public time: string = '';
}
