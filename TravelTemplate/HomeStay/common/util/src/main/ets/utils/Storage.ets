import { Order } from 'type';

export function updateOrder(orderList: Order[]) {
  AppStorage.setOrCreate('orderList', JSON.stringify(orderList));
}