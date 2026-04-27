import { Order } from 'type';

export class AppStorageBank {
  static updateOrder(orderList: Order[]) {
    AppStorage.setOrCreate('orderList', JSON.stringify(orderList));
  }
}