import { OrderBasicInfo } from 'types';
import { OrderType, StatusInfo } from './OrderModuleInfo';

@ObservedV2
export class CommodityOrderInfo implements OrderBasicInfo {
  banner: ResourceStr = '';
  orderNo: string = '';
  orderTime: string = '';
  orderStatus: number = 0;
  addressId: number = 0;
  couponId: number = 0;
  count: number = 0;
  productName: string = '';
  productPrice: number = 0;
  freight: number = 0;
  amount: number = 0;
  discount: number = 0;
  phone: string = '';
}

export const COMMODITY_ORDER_INFO_MAP: StatusInfo[] = [{
  text: '全部',
  color: '#E84026',
  opacity: 1,
}, {
  text: '待付款',
  color: '#E84026',
  opacity: 1,
},
  {
    text: '待使用',
    color: '#64BB5C',
    opacity: 1,
  },
  {
    text: '已完成',
    color: '#000000',
    opacity: 1,
  },
  {
    text: '已退款',
    color: '#000000',
    opacity: 1,
  },
];