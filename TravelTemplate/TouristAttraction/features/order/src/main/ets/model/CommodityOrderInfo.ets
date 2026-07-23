import { OrderBasicInfo } from 'types';

@ObservedV2
export class CommodityOrderInfo implements OrderBasicInfo {
  orderNo: string = '';
  orderTime: string = '';
  orderStatus: number = 0;
  addressId: number = 0;
  couponId: number = 0;
  count: number = 0;
  banner: ResourceStr = '';
  productName: string = '';
  productPrice: number = 0;
  freight: number = 0;
  amount: number = 0;
  discount: number = 0;
  phone: string = '';
}