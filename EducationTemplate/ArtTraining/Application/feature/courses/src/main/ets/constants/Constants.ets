import { CoursePaymentMap } from 'commonlib';
import { CoursePaymentMethod } from '../types/Index';

export const PAYMENT_RADIO_GROUP = 'payment';

export const PAYMENT_RADIO_LIST: CoursePaymentMethod[] = [
  {
    id:CoursePaymentMap.OFFLINE,
    value:'线下支付',
  },
  {
    id:CoursePaymentMap.ONLINE,
    value:'华为支付',
  },
];